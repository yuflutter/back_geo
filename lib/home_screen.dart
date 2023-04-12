import 'dart:async';
import 'package:flutter/material.dart';

import 'local_db.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  Timer? _timer;

  @override
  initState() {
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refresh(),
    );
    super.initState();
  }

  Future<void> _refresh() async {
    await LocalDb.reload();
    setState(() {});
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      ...LocalDb.getGeos().reversed.map(
                            (e) => Text(e),
                          ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ...LocalDb.getErrors().reversed.map(
                            (e) => Text(e, style: const TextStyle(color: Colors.red)),
                          ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Обновить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
