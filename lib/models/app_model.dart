import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppModel with ChangeNotifier {
  ThemeMode themeMode;
  bool get darkTheme => themeMode == ThemeMode.dark;

  set darkTheme(bool value) =>
      themeMode = value ? ThemeMode.dark : ThemeMode.light;

  Future getThemeFromPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.get(
      'darkTheme',
    );
    this.darkTheme = isDark ?? true;
  }

  Future<void> updateTheme(bool theme) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      darkTheme = theme;
      //TODO check this
      //Utils.changeStatusBarColor(themeMode);
      await prefs.setBool('darkTheme', theme);
      notifyListeners();
    } catch (error) {
      print('[updateTheme] error: ${error.toString()}');
    }
  }
}
