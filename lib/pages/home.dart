import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_app/components/list_story_item.dart';
import 'package:story_app/providers/auth_provider.dart';
import 'package:story_app/providers/story_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late EasyRefreshController _refreshController;

  @override
  void initState() {
    ref.read(storyProvider).getAllStory();
    _refreshController = EasyRefreshController();
    super.initState();
  }

  Future _onRefresh() async {
    await ref.read(storyProvider).getAllStory();
    if (!mounted) {
      return;
    }

    _refreshController.finishRefresh(IndicatorResult.success, true);

    return;
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRef = ref.watch(authProvider);
    final storyRef = ref.watch(storyProvider);
    if (!authRef.isLoggedIn) {
      Future.delayed(Duration.zero, () {
        ref.context.pushReplacement('/login');
      });
    }

    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(AppLocalizations.of(context)!.home),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ref.context.push('/add-story');
          },
          child: const Icon(Icons.add),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 50),
              ListTile(
                title: Text(AppLocalizations.of(context)!.logout),
                trailing: const Icon(Icons.logout),
                onTap: () async {
                  await ref.read(authProvider).logout();
                },
              ),
            ],
          ),
        ),
        body: EasyRefresh(
            controller: _refreshController,
            header: const ClassicHeader(),
            footer: const ClassicFooter(),
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
                child: storyRef.listStoryLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: storyRef.listStory.listStory.length,
                        itemBuilder: (context, index) {
                          return ListStoryItem(
                            key: ValueKey(
                                storyRef.listStory.listStory[index].id),
                            id: storyRef.listStory.listStory[index].id,
                            createdAt:
                                storyRef.listStory.listStory[index].createdAt,
                            description:
                                storyRef.listStory.listStory[index].description,
                            name: storyRef.listStory.listStory[index].name,
                            photoUrl:
                                storyRef.listStory.listStory[index].photoUrl,
                          );
                        }))));
  }
}
