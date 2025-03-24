import 'package:flutter/material.dart';
import 'package:heronfit/widgets/main_screen_wrapper.dart'; // Import MainScreenWrapper
import 'views/splash_screen.dart';
import 'views/onboarding/onboarding_hero.dart';
import 'views/auth/login_widget.dart';
import 'views/workout/add_exercise_screen.dart';
import 'views/workout/start_workout_from_template.dart'; // Import StartWorkoutFromTemplate
import 'views/workout/workout_complete_widget.dart'; // Import WorkoutCompleteWidget
import 'core/theme.dart';

class HeronFitApp extends StatelessWidget {
  const HeronFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeronFit',
      theme: HeronFitTheme.lightTheme, // Apply custom theme
      home: SplashScreenWidget(), // Start with SplashScreen
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (context) => const MainScreenWrapper());
          case '/onboarding':
            return MaterialPageRoute(builder: (context) => const OnboardingWidget());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginWidget());
          case '/add_exercise':
            return MaterialPageRoute(builder: (context) => AddExerciseScreen());
          case '/workoutComplete':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => WorkoutCompleteWidget(
                workoutId: args['workoutId'],
                workoutName: args['workoutName'],
                startTime: args['startTime'],
                endTime: args['endTime'],
                exercises: args['exercises'],
              ),
            );
          default:
            return MaterialPageRoute(builder: (context) => const SplashScreenWidget());
        }
      },
    );
  }
}
