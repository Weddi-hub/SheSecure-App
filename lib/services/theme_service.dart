import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isBlueTheme = false;

  bool get isBlueTheme => _isBlueTheme;

  Color get primaryColor => _isBlueTheme ? Colors.blue : Colors.purple;

  void toggleTheme(bool isOn) {
    _isBlueTheme = isOn;
    notifyListeners();
  }
}
