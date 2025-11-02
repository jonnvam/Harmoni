import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/app_prefs.dart';

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  bool _isTestCompleted = false;
  bool get isTestCompleted => _isTestCompleted;

  Future<void> init() async {
    await AppPrefs.instance.init();
    _isTestCompleted = AppPrefs.instance.isTestCompleted;
  }

  Future<void> setTestCompleted(bool value) async {
    _isTestCompleted = value;
    notifyListeners();
    await AppPrefs.instance.setTestCompleted(value);
  }
}
