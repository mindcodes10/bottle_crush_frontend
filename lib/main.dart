import 'package:bottle_crush/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/utils/theme_manager.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeManager()..loadTheme(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Aquazen',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeManager.themeMode, // Listen for changes
          home: const LoginScreen(),
        );
      },
    );
  }
}
