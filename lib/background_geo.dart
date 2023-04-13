import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';

import '/geo.dart';
import '/local_db.dart';

const _taskName = 'back-geo';

class BackgroundGeo {
  static Future<void> init() async {
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
    if (!(await Geolocator.isLocationServiceEnabled())) {
      await Geolocator.openLocationSettings();
    }
    if ([LocationPermission.denied, LocationPermission.deniedForever].contains(await Geolocator.checkPermission())) {
      await Geolocator.requestPermission();
    }
    if ((await Geolocator.checkPermission()) != LocationPermission.always) {
      await Geolocator.openAppSettings();
    }
    await Workmanager().cancelAll();
    await Workmanager().initialize(
      _backgroundDispatcher,
      isInDebugMode: true,
    );
    await Workmanager().registerPeriodicTask(
      _taskName,
      '$_taskName-${await LocalDb.incLastTaskId()}',
      frequency: Duration(minutes: 15), // реально в андроиде все равно будет 15
      existingWorkPolicy: ExistingWorkPolicy.append,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: Duration(seconds: 45),
      // outOfQuotaPolicy: OutOfQuotaPolicy.run_as_non_expedited_work_request,
    );
  }
}

@pragma('vm:entry-point')
void _backgroundDispatcher() {
  Workmanager().executeTask(_backgroundTask);
}

Future<bool> _backgroundTask(String task, Map<String, dynamic>? inputData) async {
  await LocalDb.init();
  final taskStart = DateTime.now();
  while (true) {
    final measureStart = DateTime.now();
    try {
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
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 45),
        // forceAndroidLocationManager: true,
      );
      await LocalDb.addGeo(Geo(
        prev: LocalDb.lastGeo,
        task: task,
        start: measureStart,
        lat: pos.latitude,
        lon: pos.longitude,
      ));
      // return false; // перезапускаем задачу, как будто возникла ошибка
    } catch (e, s) {
      LocalDb.addError(e, s); // без await, игнорим возможную ошибку записи ошибки
      LocalDb.addGeo(Geo(
        prev: LocalDb.lastGeo,
        task: task,
        start: measureStart,
        err: e.toString(),
      ));
      // return false;
    }
    if (DateTime.now().difference(taskStart).inMinutes <= 13) {
      await Future.delayed(Duration(seconds: 60));
    } else {
      break;
    }
  }
  return false; // перезапускаем задачу, как будто возникла ошибка
}
