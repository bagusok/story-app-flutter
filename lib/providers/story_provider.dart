import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/common/constant.dart';
import 'package:story_app/model/detail_story.dart';

import 'package:story_app/model/list_story_model.dart';

class StoryProvider with ChangeNotifier {
  final _dio = Dio();
  ListStoryModel _listStory = ListStoryModel(
    error: false,
    message: "",
    listStory: [],
  );
  bool listStoryError = false;
  bool listStoryLoading = false;
  bool isEndPage = false;

  bool _useLocation = true;

  StoryProvider() {
    getAllStory();
  }

  getAllStory({int page = 1, int size = 10, bool reset = false}) async {
    listStoryError = false;
    listStoryLoading = true;
    notifyListeners();
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');
      final response = await _dio.get(
          '$baseUrl/stories?page=$page&size=$size&location=${_useLocation ? 1 : 0}',
          options: Options(
              headers: {"Authorization": "Bearer $token"},
              sendTimeout: const Duration(seconds: 10)));

      if (response.data['listStory'].length == 0) {
        isEndPage = true;
        listStoryLoading = false;
        notifyListeners();
        return;
      } else {
        isEndPage = false;
        notifyListeners();
      }

      if (reset) {
        _listStory = ListStoryModel(
          error: false,
          message: "",
          listStory: [],
        );
        _listStory = ListStoryModel.fromJson(response.data);
      } else {
        _listStory = _listStory.copyWith(
          listStory: [
            ..._listStory.listStory!,
            ...response.data['listStory']
                .map((e) => StoryModel.fromJson(e))
                .toList(),
          ],
        );
      }
      listStoryLoading = false;
      notifyListeners();
      return _listStory;
    } catch (e) {
      listStoryError = true;
      listStoryLoading = false;
      notifyListeners();
      return _listStory;
    }
  }

  ListStoryModel get listStory => _listStory;

  set setUseLocation(bool value) {
    _useLocation = value;
    getAllStory(reset: true);
    notifyListeners();
  }

  get useLocation => _useLocation;
}

final storyProvider = ChangeNotifierProvider<StoryProvider>((ref) {
  return StoryProvider();
});
