import 'package:bloc/bloc.dart';
import 'package:myprogress/data/bookmark/filter/filter_data.dart';
import 'package:myprogress/data/preference/bloc/preference_bloc_event.dart';
import 'package:myprogress/data/preference/bloc/preference_bloc_state.dart';
import 'package:myprogress/data/preference/database/preference.dart';
import 'package:myprogress/data/preference/database/preference_store.dart';
import 'package:myprogress/extensions/map.dart';

class PreferenceBloc extends Bloc<PreferenceBlocEvent, PreferenceBlocState> {
  final PreferenceStore settingsStore;

  PreferenceBloc(this.settingsStore) : super(PreferenceBlocState.notReady());

  @override
  Stream<PreferenceBlocState> mapEventToState(PreferenceBlocEvent event) => event.map(
        load: _mapLoad,
        setPreference: _mapSet,
        updateFilterData: _mapUpdateFilterData,
      );

  Map<String, dynamic> _defaultPreferences() {
    return FilterData().toJson();
  }

  Stream<PreferenceBlocState> _mapLoad(LoadPreferences event) async* {
    try {
      var preferences = await settingsStore.transactionClosed((settingsStore) => settingsStore.getAll());
      var entries = await preferences.map((event) => event.toMapEntry()).toList();
      var preferenceMap = _defaultPreferences();
      preferenceMap.addEntries(entries);
      yield PreferenceBlocState.ready(version: 0, preferences: preferenceMap);
    } on Error catch (_, trace) {
      print(trace);
      yield PreferenceBlocState.notReady();
    }
  }

  Stream<PreferenceBlocState> _mapSet(SetPreference event) async* {
    yield await state.maybeMap(
        ready: (PreferencesReady ready) {
          var preference = Preference(event.key, event.value);
          return settingsStore
              .transactionClosed((settingsStore) => settingsStore.upsert(preference).then((dynamic value) {
                    ready.preferences[event.key] = event.value;

                    return ready.copyWith(version: ready.version + 1);
                  }));
        },
        orElse: () => state);
  }

  Stream<PreferenceBlocState> _mapUpdateFilterData(UpdateFilterData event) async* {
    yield await state.maybeMap(
        ready: (ready) {
          var data = event.data.toJson().mapToIterable((key, dynamic value) => Preference(key, value));
          return Future.wait<dynamic>(data.map((e) {
            ready.preferences[e.key] = e.value;
            return settingsStore.upsert(e);
          })).then((value) {
            return ready.copyWith(version: ready.version + 1);
          });
        },
        orElse: () => state);
  }
}
