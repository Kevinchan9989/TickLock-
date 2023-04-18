import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _getDarkModePreference().then((value) {
      _isDarkMode = value;
      notifyListeners();
    });
  }

  bool get isDarkMode => _isDarkMode;

  Future<bool> _getDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('darkMode') ?? false;
  }

  Future<void> _setDarkModePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _setDarkModePreference(_isDarkMode);
    notifyListeners();
  }
}
