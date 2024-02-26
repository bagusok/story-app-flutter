import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_app/common/flavor_config.dart';
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
  final ScrollController _scrollController = ScrollController();

  var page = 1;

  @override
  void initState() {
    _refreshController = EasyRefreshController();

    Future.microtask(() => ref.read(storyProvider).getAllStory(reset: true));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        if (ref.read(storyProvider).isEndPage == false &&
            ref.read(storyProvider).listStoryLoading == false) {
          ref.read(storyProvider).getAllStory(page: page + 1);
          setState(() {
            page++;
          });
        }
      }
    });

    super.initState();
  }

  Future _onRefresh() async {
    setState(() {
      page = 1;
    });
    await ref.read(storyProvider).getAllStory(reset: true);
    if (!mounted) {
      return;
    }

    _refreshController.finishRefresh(IndicatorResult.success, true);

    return;
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
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
        floatingActionButton: Column(
          children: [
            const Expanded(child: SizedBox()),
            FloatingActionButton(
              heroTag: "filter",
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: storyRef.useLocation == true
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                ),
                                onPressed: () {
                                  if (storyRef.useLocation == false) {
                                    ref.read(storyProvider).setUseLocation =
                                        true;

                                    context.pop();
                                  }
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.withLocation,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                )),
                            const SizedBox(width: 10),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: storyRef.useLocation == false
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                ),
                                onPressed: () {
                                  if (storyRef.useLocation == true) {
                                    ref.read(storyProvider).setUseLocation =
                                        false;
                                    context.pop();
                                  }
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.noLocation,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                ))
                          ]),
                        ),
                      );
                    });
              },
              child: const Icon(Icons.filter_list_alt),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "add-story",
              onPressed: () {
                ref.context.push('/add-story');
              },
              child: const Icon(Icons.add),
            )
          ],
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
              controller: _scrollController,
              child: storyRef.listStory.listStory!.isEmpty &&
                      !storyRef.listStoryLoading &&
                      !storyRef.listStoryError
                  ? const Center(
                      child: Text('No Data'),
                    )
                  : storyRef.listStoryError
                      ? const Center(child: Text('Error Ngab!'))
                      : Column(children: [
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: storyRef.listStory.listStory!.length,
                              itemBuilder: (context, index) {
                                return ListStoryItem(
                                  key: ValueKey(
                                      storyRef.listStory.listStory![index]!.id),
                                  id: storyRef.listStory.listStory![index]!.id,
                                  createdAt: storyRef
                                      .listStory.listStory![index]!.createdAt,
                                  description: storyRef
                                      .listStory.listStory![index]!.description,
                                  name: storyRef
                                      .listStory.listStory![index]!.name,
                                  photoUrl: storyRef
                                      .listStory.listStory![index]!.photoUrl,
                                );
                              }),
                          const SizedBox(height: 10),
                          ref.watch(storyProvider).listStoryLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : ref.watch(storyProvider).isEndPage
                                  ? const Center(
                                      child: Text("No Data Found"),
                                    )
                                  : const SizedBox(height: 0)
                        ]),
            )));
  }
}
