import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';

import '/geo.dart';
import '/local_db.dart';

const _taskName = 'bg';

class BackgroundGeo {
  static Future<void> init() async {
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
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: Duration(seconds: 45),
      // existingWorkPolicy: ExistingWorkPolicy.append,
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
    } catch (e, s) {
      LocalDb.addError(e, s); // без await, игнорим возможную ошибку записи ошибки
      LocalDb.addGeo(Geo(
        prev: LocalDb.lastGeo,
        task: task,
        start: measureStart,
        err: e.toString(),
      ));
    }
    await Future.delayed(Duration(seconds: 60));
    // if (DateTime.now().difference(taskStart).inMinutes <= 13) {
    //   await Future.delayed(Duration(seconds: 60));
    // } else {
    //   break;
    // }
  }
  return false; // перезапускаем задачу, как будто возникла ошибка
}
