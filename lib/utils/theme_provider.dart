import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme(); // Load saved theme on initialization
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme(_isDarkMode);
    notifyListeners();
  }

  void _saveTheme(bool isDark) async {
    await _storage.write(key: 'isDarkMode', value: isDark.toString());
  }

  void _loadTheme() async {
    String? storedValue = await _storage.read(key: 'isDarkMode');
    if (storedValue != null) {
      _isDarkMode = storedValue == 'true';
      notifyListeners();
    }
  }
}
