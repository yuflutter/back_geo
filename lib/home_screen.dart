import 'dart:async';
import 'package:flutter/material.dart';

import '/local_db.dart';

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
      Duration(seconds: 5),
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
                flex: 2,
                child: ListView(
                  children: [
                    ...LocalDb.allGeos.reversed.map(
                      (e) => Column(
                        children: [
                          Text(
                            e.toJson(),
                            style: (e.gap <= 1) ? null : TextStyle(color: Colors.purple),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ...LocalDb.allErrors.reversed.map(
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
