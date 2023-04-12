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
    LocalDb.reload();
    setState(() {});
  }

  @override
  build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Обновить'),
            ),
          ],
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
