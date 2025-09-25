import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/sign_login.dart';
import 'package:intl/date_symbol_data_local.dart'; // 👈 necesario para locales
import 'package:logger/logger.dart';

final logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  logger.d("Debug mensaje");
  logger.i("Info mensaje");
  logger.e("Error mensaje");
  await initializeDateFormatting('es_MX', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: SignLoginScreen()));
  }
}
