import 'dart:math';

import 'package:MarkMyProgress/extensions/bookmark_extensions.dart';
import 'package:MarkMyProgress/extensions/string_extensions.dart';
import 'package:json_annotation/json_annotation.dart';

import 'persistent_bookmark.dart';
import 'progress.dart';

/// <summary>
///     Base readable implementation providing utility methods for UI.
/// </summary>
abstract class BaseBookmark implements PersistentBookmark {
  @override
  @JsonKey(ignore: true)
  int key;

  @override
  @JsonKey(required: false)
  String localizedTitle;

  @override
  @JsonKey(required: false)
  String originalTitle;

  @override
  String get title {
    if (localizedTitle.isNotNullOrEmpty) {
      return localizedTitle;
    } else if (originalTitle.isNotNullOrEmpty) {
      return originalTitle;
    } else {
      return '';
    }
  }

  @override
  @JsonKey(required: false)
  double maxProgress = 0.0;

  @override
  @JsonKey(required: false)
  bool ongoing = false;

  @override
  @JsonKey(required: false)
  bool abandoned = false;

  @override
  @JsonKey(required: false)
  double progressIncrement = 1.0;

  @override
  void incrementProgress() {
    logProgress(progress + progressIncrement);
  }

  @override
  void logProgress(double progress) {
    if (!ongoing && maxProgress > 0) {
      progress = min(maxProgress, progress);
    }

    if (ongoing) {
      maxProgress = max(progress, maxProgress);
    }

    var newProgress = createNewProgress(progress);
    if (lastProgress?.date != newProgress.date) {
      history.add(newProgress);
    } else {
      history.last = newProgress;
    }
  }

  Progress createNewProgress(double progress);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseBookmark &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          localizedTitle == other.localizedTitle &&
          originalTitle == other.originalTitle &&
          maxProgress == other.maxProgress &&
          ongoing == other.ongoing &&
          abandoned == other.abandoned &&
          progressIncrement == other.progressIncrement;

  @override
  int get hashCode =>
      key.hashCode ^
      localizedTitle.hashCode ^
      originalTitle.hashCode ^
      maxProgress.hashCode ^
      ongoing.hashCode ^
      abandoned.hashCode ^
      progressIncrement.hashCode;
}
