import 'package:flutter/material.dart';
import 'package:inventaris_flutter/pages/authpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharmacin',
      theme: ThemeData(
        // Set the primary color to a dark grey
        primaryColor: const Color(0xFF333333),
        // Set the accent color to a lighter grey
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF666666),
        ),
        // Set the background color to white
        scaffoldBackgroundColor: Colors.white,
        // Customize the app bar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF333333),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        // Customize text themes
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFF333333)),
          displayMedium: TextStyle(color: Color(0xFF333333)),
          bodyLarge: TextStyle(color: Color(0xFF666666)),
          bodyMedium: TextStyle(color: Color(0xFF666666)),
        ),
        // Customize button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF333333),
            foregroundColor: Colors.white,
          ),
        ),
        // Customize input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF666666)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
        ),
      ),
      home: const Authpage(),
    );
  }
}
