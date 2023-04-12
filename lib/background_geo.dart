import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';

import 'local_db.dart';

const _taskName = 'backgroundGeo';

class BackgroundGeo {
  static Future<void> init() async {
    if ((await Geolocator.checkPermission()) == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    await Workmanager().initialize(backgroundDispatcher);
    await Workmanager().registerPeriodicTask(
      _taskName,
      '$_taskName-01',
      frequency: const Duration(seconds: 10), // really 15 min
    );
  }
}

@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await LocalDb.init();
      final geo = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );
      await LocalDb.addGeo('${geo.latitude}, ${geo.longitude}');
      return true;
    } catch (e, s) {
      print('$e\n$s');
      return Future.error(e, s);
    }
  });
}