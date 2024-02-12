import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/common/constant.dart';
import 'package:story_app/model/list_story_model.dart';

class StoryProvider with ChangeNotifier {
  final _dio = Dio();
  ListStoryModel _listStory = ListStoryModel.fromJson(
      {"error": false, "message": "Success", "listStory": []});
  bool listStoryError = false;
  bool listStoryLoading = false;

  StoryProvider() {
    getAllStory();
  }

  getAllStory() async {
    listStoryError = false;
    listStoryLoading = true;
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');
      final response = await _dio.get('$base_url/stories',
          options: Options(headers: {"Authorization": "Bearer $token"}));

      _listStory = ListStoryModel.fromJson(response.data);
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
}

final storyProvider = ChangeNotifierProvider<StoryProvider>((ref) {
  return StoryProvider();
});
