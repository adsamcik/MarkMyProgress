import 'dart:async';

import 'package:MarkMyProgress/data/bookmark/filter/FilterData.dart';
import 'package:MarkMyProgress/data/preference/database/preference.dart';
import 'package:MarkMyProgress/data/storage/abstraction/data_source.dart';
import 'package:MarkMyProgress/data/storage/storage.dart';

class SettingsStore extends Storage<String, Preference> {
  SettingsStore(DataSource<String, Preference> dataSource) : super(dataSource);

  Future<Map<String, dynamic>> getFilterMap() async {
    var filterDataMap = FilterData().toJson();

    var data = await getAllWithKeys(filterDataMap.keys);

    await data.forEach((element) {
      if (element != null) {
        filterDataMap[element.key] = element.value;
      }
    });

    return filterDataMap;
  }

  /// Loads filter data from database
  Future<FilterData> getFilterData() async {
    var filterDataMap = await getFilterMap();
    return FilterData.fromJson(filterDataMap);
  }

  @override
  Future<T> transaction<T>(
      FutureOr<T> Function(SettingsStore settingsStore) action) async {
    await open();
    var result = await action(this);
    await close();
    return result;
  }
}