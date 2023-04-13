import 'dart:convert';

class Geo {
  late int gap;
  late int dur;
  late String task;
  late DateTime start;
  late DateTime end;
  double? lat;
  double? lon;
  String? err;

  Geo({Geo? prev, required this.task, required this.start, this.lat, this.lon, this.err}) {
    gap = (prev != null) ? start.difference(prev.end).inMinutes : 0;
    end = DateTime.now();
    dur = end.difference(start).inSeconds;
  }

  Geo.fromJson(String json) {
    final m = jsonDecode(json) as Map;
    gap = m['gap'];
    dur = m['dur'];
    task = m['task'];
    start = DateTime.parse(m['start']);
    end = DateTime.parse(m['end']);
    lat = m['lat'];
    lon = m['lon'];
    err = m['err'];
  }

  String toJson() {
    final m = {
      'gap': gap,
      'dur': dur,
      'task': task,
      'start': start.toString(),
      'end': end.toString(),
      'lat': lat,
      'lon': lon,
    };
    if (err != null) m['err'] = err;
    return jsonEncode(m);
  }
}
