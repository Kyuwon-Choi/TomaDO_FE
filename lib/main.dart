import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tomado/screens/home_screen.dart';
import 'package:tomado/screens/login_screen.dart';
import 'package:tomado/screens/splash_screen.dart';

void main() async {
  // import 는 package:intl/date_symbol_data_local.dart
  await initializeDateFormatting();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          backgroundColor: const Color(0xffF2F3F5),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xff353954),
          ),
        ),
        cardColor: const Color(0xffff452c),
        canvasColor: const Color(0xfffD6b56),
      ),
      home: const SplashScreen(),
    );
  }
}
