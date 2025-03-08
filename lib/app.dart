import 'package:flutter/material.dart';
import 'views/splash_screen.dart';
import 'core/theme.dart';

class HeronFitApp extends StatelessWidget {
  const HeronFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeronFit',
      theme: HeronFitTheme.lightTheme,  // Apply custom theme
      home: SplashScreen(),  // Start with SplashScreen
    );
  }
}
