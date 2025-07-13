import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';

import 'package:logger/logger.dart';

final logger = Logger();

void main() {
  logger.d("Debug mensaje");
  logger.i("Info mensaje");
  logger.e("Error mensaje");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: IaScreen()));
  }
}
