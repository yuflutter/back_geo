import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

const _geosKey = 'geos';
const _errorsKey = 'errors';

class LocalDb {
  static late final SharedPreferences _db;

  static Future<void> init() async {
    _db = await SharedPreferences.getInstance();
    if (_db.getStringList(_geosKey) == null) {
      await _db.setStringList(_geosKey, []);
    }
    if (_db.getStringList(_errorsKey) == null) {
      await _db.setStringList(_errorsKey, []);
    }
  }

  static Future<void> reload() => _db.reload();

  static List<String> getGeos() => _db.getStringList(_geosKey) ?? [];
  static Future<void> addGeo(Map geo) async {
    await _db.setStringList(_geosKey, getGeos()..add(geo.toString()));
  }

  static List<String> getErrors() => _db.getStringList(_errorsKey) ?? [];
  static Future<void> addError(dynamic error, [StackTrace? stack]) async {
    final s = (stack != null) ? '$error\n$stack' : '$error';
    log(s);
    await _db.setStringList(_errorsKey, getErrors()..add(s));
  }
}
