import 'package:flutter/material.dart';

class AppTheme {
  // Define your gradient colors
  static const Color startColor = Color(0xFF0B499E); // #0B499E
  static const Color endColor = Color(0xFF1E92F5);   // #1E92F5
  static const Color textColor = Colors.white;        // White text color

  // Define the gradient
  static const LinearGradient appGradient = LinearGradient(
    colors: [
      startColor,
      endColor,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

}