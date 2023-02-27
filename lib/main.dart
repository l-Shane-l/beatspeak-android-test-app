import 'package:flutter/material.dart';
import 'heart_rate_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movesense Heart Rate',
      home: HeartRateScreen(),
    );
  }
}