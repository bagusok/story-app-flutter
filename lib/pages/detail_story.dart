import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/common/constant.dart';
import 'package:story_app/common/flavor_config.dart';
import 'package:story_app/model/detail_story.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DetailStoryPage extends StatefulWidget {
  final String id;
  const DetailStoryPage({super.key, required this.id});

  @override
  State<DetailStoryPage> createState() => _DetailStoryPageState();
}

class _DetailStoryPageState extends State<DetailStoryPage> {
  var _isLoading = false;
  var _isError = false;
  late DetailStoryModel data;

  void _fetchData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final dio = Dio();
      final sharedPreferences = await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');
      final response = await dio.get('$baseUrl/stories/${widget.id}',
          options: Options(headers: {"Authorization": "Bearer $token"}));

      data = DetailStoryModel.fromJson(response.data);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoading && !_isError
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _isError
                  ? const Center(
                      child: Text('Error Ngab!'),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  data.story!.photoUrl,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.story!.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    data.story!.createdAt,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {},
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                data.story!.photoUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data.story!.description,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          data.story?.lat != null && data.story?.lon != null
                              ? ElevatedButton(
                                  onPressed: () {
                                    context.push(
                                        '/user-location/${data.story!.name}/${data.story!.lat}/${data.story!.lon}');
                                  },
                                  child: Text(AppLocalizations.of(context)!
                                      .viewLocation))
                              : const SizedBox(),
                        ],
                      ),
                    )),
    );
  }
}
