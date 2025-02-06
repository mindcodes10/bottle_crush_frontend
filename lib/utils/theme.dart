import 'package:flutter/material.dart';

class AppTheme {
  static const Color startColor = Color(0xFF0B499E);
  static const Color endColor = Color(0xFF1E92F5);
  static const Color textWhite = Colors.white;
  static const Color textBlack = Colors.black;
  static const Color backgroundWhite = Colors.white;
  static const Color backgroundBlue = Color(0xFF0B499E);
  static const Color backgroundCard = Color(0xFFFAFAFA);
  static const Color transparent = Colors.transparent;
  static const Color backgroundDark = Colors.black45;

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Merriweather',
    primaryColor: backgroundBlue,
    scaffoldBackgroundColor: backgroundWhite,
    colorScheme: const ColorScheme.light(
      primary: backgroundBlue,
      secondary: endColor,
      background: backgroundWhite,
      onBackground: textBlack,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundWhite,
      iconTheme: IconThemeData(color: textBlack),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Merriweather',
    primaryColor: backgroundDark,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: backgroundDark,
      secondary: endColor,
      background: Colors.black,
      onBackground: textWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      iconTheme: IconThemeData(color: textWhite),
    ),
  );
}