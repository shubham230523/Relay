import 'package:flutter/material.dart';

class RelayApp extends StatelessWidget {
  const RelayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Relay',
      home: Scaffold(
        body: Center(
          child: Text('Relay'),
        ),
      ),
    );
  }
}
