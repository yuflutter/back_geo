import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';

import 'local_db.dart';

const _taskName = 'backgroundGeo';

class BackgroundGeo {
  // static late final Location _loc;

  static Future<void> init() async {
    if ((await Geolocator.checkPermission()) == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    // _loc = Location();
    // if (!(await _loc.serviceEnabled()) && !(await _loc.requestService())) {
    //   LocalDb.addError('Включите геолокацию');
    //   return;
    // }
    // if ((await _loc.hasPermission()) == PermissionStatus.denied &&
    //     (await _loc.requestPermission()) != PermissionStatus.granted) {
    //   LocalDb.addError('Предоставьте разрешения');
    //   return;
    // }
    await Workmanager().initialize(
      _backgroundDispatcher,
      isInDebugMode: true,
    );
    await Workmanager().registerPeriodicTask(
      _taskName,
      '$_taskName-01',
      frequency: const Duration(minutes: 5), // реально в андроиде все равно будет 15
      backoffPolicy: BackoffPolicy.linear,
      //backoffPolicyDelay: Duration(seconds: 30),
    );
  }
}

@pragma('vm:entry-point')
void _backgroundDispatcher() {
  Workmanager().executeTask(_backgroundTask);
}

Future<bool> _backgroundTask(String task, Map<String, dynamic>? inputData) async {
  try {
    await LocalDb.init();
    // final _loc = Location();
    // if (!(await _loc.serviceEnabled()) && !(await _loc.requestService())) {
    //   LocalDb.addError('Включите геолокацию');
    //   return false;
    // }
    // if ((await _loc.hasPermission()) == PermissionStatus.denied &&
    //     (await _loc.requestPermission()) != PermissionStatus.granted) {
    //   LocalDb.addError('Предоставьте разрешения');
    //   return false;
    // }
    // final geo = await _loc.getLocation();
    final geo = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      // forceAndroidLocationManager: true,
      timeLimit: const Duration(seconds: 45),
    );
    await LocalDb.addGeo('${geo.latitude}, ${geo.longitude}');
    return false; // перезапускаем задачу, как будто возникла ошибка
  } catch (e, s) {
    LocalDb.addError(e, s); // без await, игнорим возможную ошибку записи ошибки
    return false;
  }
}
