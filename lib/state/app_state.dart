import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/app_prefs.dart';
<<<<<<< HEAD
import 'package:flutter_application_1/models/user_role.dart';
=======
>>>>>>> feature/stabilize-before-main

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  bool _isTestCompleted = false;
  bool get isTestCompleted => _isTestCompleted;

<<<<<<< HEAD
  UserRole _role = UserRole.paciente;
  UserRole get role => _role;

  Future<void> init() async {
    await AppPrefs.instance.init();
    _isTestCompleted = AppPrefs.instance.isTestCompleted;
    _role = UserRoleX.from(AppPrefs.instance.role);
=======
  Future<void> init() async {
    await AppPrefs.instance.init();
    _isTestCompleted = AppPrefs.instance.isTestCompleted;
>>>>>>> feature/stabilize-before-main
  }

  Future<void> setTestCompleted(bool value) async {
    _isTestCompleted = value;
    notifyListeners();
    await AppPrefs.instance.setTestCompleted(value);
  }
<<<<<<< HEAD

  Future<void> setRole(UserRole role) async {
    _role = role;
    notifyListeners();
    await AppPrefs.instance.setRole(role.key);
  }
=======
>>>>>>> feature/stabilize-before-main
}
