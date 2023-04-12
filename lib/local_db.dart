import 'package:shared_preferences/shared_preferences.dart';

const _geosKey = 'geos';

class LocalDb {
  static late final SharedPreferences _db;

  static Future<void> init() async {
    _db = await SharedPreferences.getInstance();
    var geos = _db.getStringList(_geosKey);
    if (geos == null) {
      geos = [];
      await _db.setStringList(_geosKey, geos);
    }
  }

  static Future<void> reload() async {
    await _db.reload();
  }

  static List<String> getGeos() {
    return _db.getStringList(_geosKey) ?? [];
  }

  static Future<void> addGeo(String geo) async {
    await _db.setStringList(_geosKey, getGeos()..add(geo));
  }
}
