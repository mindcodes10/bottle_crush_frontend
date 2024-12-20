import 'package:flutter/material.dart';

class AppTheme {
  // Define your gradient colors
  static const Color startColor = Color(0xFF0B499E); // #0B499E
  static const Color endColor = Color(0xFF1E92F5);   // #1E92F5
  static const Color textWhite = Colors.white;        // White text color
  static const Color textBlack = Colors.black;        // White text color
  static const Color backgroundWhite = Colors.white;
  static const Color backgroundBlue = Color(0xFF0B499E);

  // Define the gradient
  static const LinearGradient appGradient = LinearGradient(
    colors: [
      startColor,
      endColor,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

}