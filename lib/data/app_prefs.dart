import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static final AppPrefs instance = AppPrefs._();
  AppPrefs._();

  static const _kTestCompleted = 'isTestCompleted';
<<<<<<< HEAD
  static const _kUserRole = 'userRole';
=======
>>>>>>> feature/stabilize-before-main

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool get isTestCompleted => _prefs?.getBool(_kTestCompleted) ?? false;

  Future<void> setTestCompleted(bool value) async {
    await _prefs?.setBool(_kTestCompleted, value);
  }
<<<<<<< HEAD

  String? get role => _prefs?.getString(_kUserRole);
  Future<void> setRole(String role) async {
    await _prefs?.setString(_kUserRole, role);
  }
=======
>>>>>>> feature/stabilize-before-main
}
