import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/sign_login.dart';
import 'package:intl/date_symbol_data_local.dart'; // 👈 necesario para locales
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // este archivo se genera con flutterfire configure
<<<<<<< HEAD
import 'package:flutter_application_1/state/app_state.dart';
=======
import 'package:flutter_dotenv/flutter_dotenv.dart';
>>>>>>> origin/cambiosJacque

final logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
<<<<<<< HEAD
  await AppState.instance.init();
=======
  await dotenv.load(fileName: 'assets/env/.env'); // cargar .env
>>>>>>> origin/cambiosJacque

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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Scaffold(body: SignLoginScreen()),
    );

  }
}
