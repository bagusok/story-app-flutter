import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'detail_story.freezed.dart';
part 'detail_story.g.dart';

@freezed
class DetailStoryModel with _$DetailStoryModel {
  const factory DetailStoryModel({
    required bool error,
    required String message,
    StoryModel? story,
  }) = _DetailStoryModel;

  factory DetailStoryModel.fromJson(Map<String, dynamic> json) =>
      _$DetailStoryModelFromJson(json);
}

@freezed
class StoryModel with _$StoryModel {
  const factory StoryModel({
    required String id,
    required String name,
    required String description,
    required String photoUrl,
    required String createdAt,
    double? lat,
    double? lon,
  }) = _StoryModel;

  factory StoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoryModelFromJson(json);
}
