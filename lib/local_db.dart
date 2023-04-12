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

  static Future<void> reload() async {
    await _db.reload();
  }

  static List<String> getGeos() => _db.getStringList(_geosKey) ?? [];
  static Future<void> addGeo(String geo) => _db.setStringList(_geosKey, getGeos()..add(geo));

  static List<String> getErrors() => _db.getStringList(_errorsKey) ?? [];
  static Future<void> addError(dynamic e, [StackTrace? s]) => _db.setStringList(_errorsKey, getGeos()..add('$e\n$s'));
}
