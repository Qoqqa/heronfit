import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import necessary screen/widget files
import 'package:heronfit/features/splash/views/splash_screen.dart'; // Import Splash Screen
import 'package:heronfit/features/auth/views/login_widget.dart';
import 'package:heronfit/features/auth/views/register_screen.dart';
import 'package:heronfit/features/auth/views/register_verification.dart';
import 'package:heronfit/features/home/views/home_screen.dart';
import 'package:heronfit/features/profile/views/profile_screen.dart';
import 'package:heronfit/features/profile/views/edit_profile.dart';
import 'package:heronfit/features/workout/views/workout_history_widget.dart';
import 'package:heronfit/features/profile/views/contactUs_screen.dart';
import 'package:heronfit/features/profile/views/privacyPolicy_screen.dart';
import 'package:heronfit/features/profile/views/termsOfUse_screen.dart';
import 'package:heronfit/features/booking/views/my_bookings.dart';
import 'package:heronfit/features/booking/views/booking_screen.dart';
import 'package:heronfit/features/workout/views/workout_widget.dart';
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/views/workout_complete_widget.dart';
import 'package:heronfit/features/workout/views/add_exercise_screen.dart';
import 'package:heronfit/features/workout/views/start_new_workout_widget.dart';
import 'package:heronfit/features/workout/views/start_workout_from_template.dart';
import 'package:heronfit/features/progress/views/progress_screen.dart';
import 'package:heronfit/features/progress/views/edit_goals.dart';
import 'package:heronfit/features/progress/views/update_weight.dart';
import 'package:heronfit/features/progress/views/progress_tracker.dart';
import 'package:heronfit/features/progress/views/progress_photo_list.dart';
import 'package:heronfit/features/onboarding/views/onboarding_hero.dart';
import 'package:heronfit/widgets/main_screen_wrapper.dart';

import 'app_routes.dart';

// Navigator keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash, // Ensure this is set to the splash route
    debugLogDiagnostics: true,
    routes: [
      // Add Splash Screen Route
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreenWidget(),
      ),
      // Routes outside the main navigation shell
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingWidget(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginWidget(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterWidget(),
        routes: [
          GoRoute(
            path: 'verify',
            name: AppRoutes.registerVerify,
            builder: (context, state) {
              final args = state.extra as Map<String, String>? ?? {};
              return RegisterVerificationWidget(
                email: args['email'] ?? '',
                password: args['password'] ?? '',
                confirmPassword: args['confirmPassword'] ?? '',
                firstName: args['firstName'] ?? '',
                lastName: args['lastName'] ?? '',
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.workoutStartNew,
        builder: (context, state) => const StartNewWorkoutWidget(),
      ),
      GoRoute(
        path: AppRoutes.workoutStartFromTemplate,
        builder: (context, state) {
          final workout = state.extra as Workout?;
          if (workout != null) {
            return StartWorkoutFromTemplate(workout: workout);
          }
          return const Scaffold(
            body: Center(child: Text("Workout data missing")),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.workoutAddExercise,
        builder: (context, state) => const AddExerciseScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutComplete,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return WorkoutCompleteWidget(
            workoutId: args['workoutId'] as String? ?? 'unknown_id',
            startTime: args['startTime'] as DateTime? ?? DateTime.now(),
            endTime: args['endTime'] as DateTime? ?? DateTime.now(),
            workoutName: args['workoutName'] as String? ?? 'Unnamed Workout',
            exercises: List<String>.from(args['exercises'] as List? ?? []),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.progressEditGoals,
        builder: (context, state) => const EditGoalsWidget(),
      ),
      GoRoute(
        path: AppRoutes.progressUpdateWeight,
        builder: (context, state) => const UpdateWeightWidget(),
      ),
      GoRoute(
        path: AppRoutes.progressTracker,
        builder: (context, state) => const ProgressTrackerWidget(),
      ),
      GoRoute(
        path: AppRoutes.progressPhotoList,
        builder: (context, state) => const ProgressPhotosListWidget(),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        builder: (context, state) => const EditProfileWidget(),
      ),
      GoRoute(
        path: AppRoutes.profileHistory,
        builder: (context, state) => const WorkoutHistoryWidget(),
      ),
      GoRoute(
        path: AppRoutes.profileContact,
        builder: (context, state) => const ContactUsWidget(),
      ),
      GoRoute(
        path: AppRoutes.profilePrivacy,
        builder: (context, state) => const PrivacyPolicyWidget(),
      ),
      GoRoute(
        path: AppRoutes.profileTerms,
        builder: (context, state) => const TermsOfUseWidget(),
      ),
      GoRoute(
        path: AppRoutes.bookings,
        builder: (context, state) => const MyBookingsWidget(),
      ),
      // ShellRoute for main app sections
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScreenWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeWidget(),
          ),
          GoRoute(
            path: AppRoutes.booking,
            builder: (context, state) => const BookingScreen(),
          ),
          GoRoute(
            path: AppRoutes.workout,
            builder: (context, state) {
              final workoutData = state.extra as Map<String, dynamic>?;
              return WorkoutWidget(workoutData: workoutData);
            },
          ),
          GoRoute(
            path: AppRoutes.progress,
            builder: (context, state) => const ProgressDashboardWidget(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Page not found: ${state.error}')),
        ),
  );
});
