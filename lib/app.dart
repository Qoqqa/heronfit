import 'package:flutter/material.dart';
import 'views/splash_screen.dart';  // Import SplashScreen

class HeronFitApp extends StatelessWidget {
  const HeronFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeronFit',
      theme: ThemeData.light(),  // Apply default light theme
      home: SplashScreen(),  // Start with SplashScreen
    );
  }
}
