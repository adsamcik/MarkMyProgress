﻿import 'dart:io';

import 'package:MarkMyProgress/data/abstract/IPersistentBookmark.dart';

/// <summary>
///     Interface for data exporting.
/// </summary>
abstract class IDataExporter {
  /// <summary>
  ///     Array of all supported extensions
  /// </summary>
  Iterable<String> get exportExtensions;

  /// <summary>
  ///     Exports data from readables to a file.
  /// </summary>
  /// <param name="bookmarks"></param>
  /// <param name="file"></param>
  Future export(Iterable<IPersistentBookmark> bookmarks, File file);
}