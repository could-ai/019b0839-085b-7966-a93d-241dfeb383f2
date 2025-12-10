import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Gratitude',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF43F5E), // Rose color
          primary: const Color(0xFFF43F5E),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Default, but good to be explicit if we add fonts later
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const GratitudeHomeScreen(),
      },
    );
  }
}
