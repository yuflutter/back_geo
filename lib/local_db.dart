import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

import '/geo.dart';

const _allGeosKey = 'allGeos';
const _lastGeoKey = 'lastGeo';
const _errorsKey = 'errors';

class LocalDb {
  static late final SharedPreferences _db;

  static Future<void> init() async {
    _db = await SharedPreferences.getInstance();
    // if (_db.getStringList(_allGeosKey) == null) {
    //   await _db.setStringList(_allGeosKey, []);
    // }
    // if (_db.getStringList(_errorsKey) == null) {
    //   await _db.setStringList(_errorsKey, []);
    // }
  }

  static Future<void> reload() async {
    await _db.reload();
  }

  static List<String> get allGeosJson => _db.getStringList(_allGeosKey) ?? [];

  static List<Geo> get allGeos => allGeosJson.map<Geo>((e) => Geo.fromJson(e)!).toList();

  static Geo? get lastGeo {
    final json = _db.getString(_lastGeoKey);
    return (json != null) ? Geo.fromJson(json) : null;
  }

  static Future<void> addGeo(Geo geo) async {
    final geoJson = geo.toJson();
    await Future.wait([
      _db.setStringList(_allGeosKey, allGeosJson..add(geoJson)),
      _db.setString(_lastGeoKey, geoJson),
    ]);
  }

  static List<String> get allErrors => _db.getStringList(_errorsKey) ?? [];

  static Future<void> addError(dynamic error, [StackTrace? stack]) async {
    log('$error', stackTrace: stack);
    await _db.setStringList(_errorsKey, allErrors..add((stack != null) ? '$error\n$stack' : '$error'));
  }
}
