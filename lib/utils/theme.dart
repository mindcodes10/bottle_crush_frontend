import 'package:flutter/material.dart';

//class AppTheme {
const Color startColor = Color(0xFF0B499E);
const Color endColor = Color(0xFF1E92F5);
const Color textWhite = Colors.white;
const Color textBlack = Colors.black;
const Color backgroundWhite = Colors.white;
const Color backgroundBlue = Color(0xFF0B499E);
const Color backgroundCard = Color(0xFFFAFAFA);
const Color transparent = Colors.transparent;
Color cardDark = Colors.grey[900]!;
const Color backgroundDark = Colors.black45;
//Color backgroundGrey = Colors.grey[900]!;


// Light Theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Merriweather',
  primaryColor: backgroundBlue,
  scaffoldBackgroundColor: backgroundWhite,
  // colorScheme: const ColorScheme.light(
  //   primary: backgroundBlue,
  //   secondary: endColor,
  //   background: backgroundWhite,
  //   onBackground: textBlack,
  // ),
  // appBarTheme: const AppBarTheme(
  //   backgroundColor: backgroundWhite,
  //   iconTheme: IconThemeData(color: backgroundBlue),
  // ),
  // elevatedButtonTheme: ElevatedButtonThemeData(
  //   style: ButtonStyle(
  //     backgroundColor: MaterialStateProperty.all<Color>(backgroundBlue),
  //     foregroundColor: MaterialStateProperty.all<Color>(textWhite),
  //   ),
  // ),
  // iconTheme: const IconThemeData(color: backgroundBlue),
  // iconButtonTheme: IconButtonThemeData(
  //   style: ButtonStyle(
  //     foregroundColor: MaterialStateProperty.all<Color>(backgroundBlue),
  //   ),
  // ),

);

// Dark Theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Merriweather',
  primaryColor: backgroundDark,
  scaffoldBackgroundColor: textBlack,
  // colorScheme: const ColorScheme.dark(
  //   primary: backgroundDark,
  //   secondary: endColor,
  //   background: Colors.black,
  //   onBackground: textWhite,
  // ),
  // appBarTheme: AppBarTheme(
  //   backgroundColor: backgroundGrey,
  //   iconTheme: const IconThemeData(color: textWhite),
  // ),
  // cardTheme: CardTheme(
  //   color: cardDark,
  // ),
  // elevatedButtonTheme: const ElevatedButtonThemeData(
  //   // style: ButtonStyle(
  //   //   backgroundColor: MaterialStateProperty.all<Color>(cardDark),
  //   //   foregroundColor: MaterialStateProperty.all<Color>(textWhite),
  //   // ),
  // ),
  // inputDecorationTheme: InputDecorationTheme(
  //   filled: true,
  //   fillColor: cardDark,
  //   border: const OutlineInputBorder( // Default border
  //     borderRadius: BorderRadius.all(Radius.circular(8.0)),
  //     borderSide: BorderSide(color: Colors.grey, width: 1.0),
  //   ),
  //   enabledBorder: const OutlineInputBorder( // Border when field is enabled but not focused
  //     borderRadius: BorderRadius.all(Radius.circular(8.0)),
  //     borderSide: BorderSide(color: textWhite, width: 1.0),
  //   ),
  //   focusedBorder: const OutlineInputBorder( // Border when field is focused
  //     borderRadius: BorderRadius.all(Radius.circular(8.0)),
  //     borderSide: BorderSide(color: textWhite, width: 1.0),
  //   ),
  //   labelStyle: const TextStyle(
  //     color: textWhite,
  //     fontSize: 14,
  //   ),
  // ),
);
//}
