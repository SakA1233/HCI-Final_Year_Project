import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isHighContrast = false;
  double _textScaleFactor = 1.0;
  bool _isTextToSpeechEnabled = false;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get isHighContrast => _isHighContrast;
  double get textScaleFactor => _textScaleFactor;
  bool get isTextToSpeechEnabled => _isTextToSpeechEnabled;

  // Constructor loads saved preferences
  ThemeProvider() {
    _loadPreferences();
  }

  // Load saved preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isHighContrast = prefs.getBool('isHighContrast') ?? false;
    _textScaleFactor = prefs.getDouble('textScaleFactor') ?? 1.0;
    _isTextToSpeechEnabled = prefs.getBool('isTextToSpeechEnabled') ?? false;
    notifyListeners();
  }

  // Save preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('isHighContrast', _isHighContrast);
    await prefs.setDouble('textScaleFactor', _textScaleFactor);
    await prefs.setBool('isTextToSpeechEnabled', _isTextToSpeechEnabled);
  }

  // Toggle dark mode
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _savePreferences();
    notifyListeners();
  }

  // Toggle high contrast
  void toggleHighContrast() {
    _isHighContrast = !_isHighContrast;
    _savePreferences();
    notifyListeners();
  }

  // Set text scale factor
  void setTextScaleFactor(double factor) {
    _textScaleFactor = factor;
    _savePreferences();
    notifyListeners();
  }

  // Toggle text-to-speech
  void toggleTextToSpeech() {
    _isTextToSpeechEnabled = !_isTextToSpeechEnabled;
    _savePreferences();
    notifyListeners();
  }

  // Get the current theme
  ThemeData getTheme() {
    if (_isDarkMode) {
      return _isHighContrast ? _highContrastDarkTheme : _darkTheme;
    } else {
      return _isHighContrast ? _highContrastLightTheme : _lightTheme;
    }
  }

  // Light theme
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.lightBlue[700],
    colorScheme: ColorScheme.light(
      primary: Colors.lightBlue[700]!,
      secondary: Colors.lightBlue[300]!,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.lightBlue[700],
      foregroundColor: Colors.white,
    ),
  );

  // Dark theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.lightBlue[700],
    colorScheme: ColorScheme.dark(
      primary: Colors.lightBlue[700]!,
      secondary: Colors.lightBlue[300]!,
    ),
  );

  // High contrast light theme
  final ThemeData _highContrastLightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.black,
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Colors.black,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      titleLarge: TextStyle(color: Colors.black),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
  );

  // High contrast dark theme
  final ThemeData _highContrastDarkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.white,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: Colors.white,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      background: Colors.black,
      onBackground: Colors.white,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
  );
}
