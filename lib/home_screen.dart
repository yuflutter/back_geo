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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
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
                          (e) => Column(
                            children: [
                              Divider(color: Colors.red),
                              Text(e, style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _refresh,
                child: Text('Обновить'),
              ),
            ],
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
