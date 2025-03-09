import 'package:flutter/material.dart';
import 'package:heronfit/views/home/home_screen.dart';
import 'views/splash_screen.dart';
import 'views/home/home_screen.dart';
import 'views/onboarding/onboarding_hero.dart';
import 'views/auth/login_widget.dart';
import 'views/workout/add_exercise_screen.dart';
import 'core/theme.dart';

class HeronFitApp extends StatelessWidget {
  const HeronFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeronFit',
      theme: HeronFitTheme.lightTheme,  // Apply custom theme
      home: SplashScreenWidget(),  // Start with SplashScreen
      routes: {
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingWidget(),
        '/login': (context) => const LoginWidget(),
        '/add_exercise': (context) => AddExerciseScreen(),
      },
    );
  }
}
