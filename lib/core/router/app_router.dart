import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/booking/views/booking_screen.dart';
import 'package:heronfit/features/booking/views/my_bookings.dart';
import 'package:heronfit/features/workout/views/workout_screen.dart';

// Import necessary screen/widget files
import 'package:heronfit/features/splash/views/splash_screen.dart'; // Import Splash Screen
import 'package:heronfit/features/auth/views/login_screen.dart';
import 'package:heronfit/features/auth/views/register_screen.dart';
import 'package:heronfit/features/auth/views/register_verification.dart'
    as reg_verify;
import 'package:heronfit/features/home/views/home_screen.dart';
import 'package:heronfit/features/profile/views/profile_screen.dart';
import 'package:heronfit/features/profile/views/edit_profile.dart';
import 'package:heronfit/features/workout/views/workout_history_screen.dart'; // Added import
import 'package:heronfit/features/profile/views/contact_us_screen.dart';
import 'package:heronfit/features/profile/views/privacy_policy_screen.dart';
import 'package:heronfit/features/booking/views/activate_gym_pass_screen.dart';
import 'package:heronfit/features/booking/views/booking_success_summary.dart';
import 'package:heronfit/features/booking/views/confirm_booking.dart';
import 'package:heronfit/features/booking/views/confirm_details.dart';
import 'package:heronfit/features/booking/views/my_bookings.dart'; // Added import
import 'package:heronfit/features/workout/models/workout_model.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart'; // Import Exercise model
import 'package:heronfit/features/workout/views/workout_complete_screen.dart'; // Added import
import 'package:heronfit/features/workout/views/add_exercise_screen.dart'; // Corrected import path
import 'package:heronfit/features/workout/views/start_new_workout_screen.dart';
import 'package:heronfit/features/workout/views/start_workout_from_template_screen.dart'; // Added import
import 'package:heronfit/features/workout/views/my_workout_templates_screen.dart'; // Import the new screen
import 'package:heronfit/features/workout/views/recommended_workouts_screen.dart'; // Import the new screen
import 'package:heronfit/features/progress/views/progress_screen.dart'; // Corrected import
import 'package:heronfit/features/progress/views/edit_goals.dart';
import 'package:heronfit/features/progress/views/update_weight.dart';
import 'package:heronfit/features/progress/views/progress_tracker.dart';
import 'package:heronfit/features/progress/views/progress_photo_list.dart';
import 'package:heronfit/features/progress/views/progress_details_screen.dart'; // Import Progress Details Screen
import 'package:heronfit/features/progress/views/view_progress_photo.dart'; // Import ViewProgressPhotosWidget
import 'package:heronfit/features/progress/views/compare_progress_photo.dart'; // Import CompareProgressPhotosWidget
import 'package:heronfit/features/onboarding/views/onboarding_screen.dart';
import 'package:heronfit/features/workout/views/exercise_details_screen.dart'; // Import Exercise Details Screen
import 'package:heronfit/features/workout/views/workout_details_screen.dart';
import 'package:heronfit/widgets/main_screen_wrapper.dart';
import 'package:heronfit/features/auth/views/register_getting_to_know_screen.dart';
import 'package:heronfit/features/auth/views/register_set_goals_screen.dart';
import 'package:heronfit/features/auth/views/register_success_screen.dart';
import 'package:heronfit/features/auth/views/request_otp_screen.dart'; // New import
import 'package:heronfit/features/auth/views/enter_otp_screen.dart'; // New import
import 'package:heronfit/features/auth/views/create_new_password_screen.dart'; // New import
import 'package:heronfit/features/notifications/views/notifications_screen.dart';
import 'package:heronfit/features/notifications/views/notification_details_screen.dart';

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
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.requestOtp, // Changed from AppRoutes.forgotPassword
        builder:
            (context, state) =>
                const RequestOtpScreen(), // Changed from ForgotPasswordScreen
      ),
      GoRoute(
        path: AppRoutes.enterOtp,
        name:
            AppRoutes
                .enterOtp, // Added name for type safety with pushReplacementNamed
        builder: (context, state) {
          final email = state.extra as String?;
          if (email == null) {
            // If email is not provided, redirect back or show an error
            // For simplicity, redirecting to requestOtp. Consider a dedicated error screen.
            return const RequestOtpScreen(); // Or some error/redirect logic
          }
          return EnterOtpScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.createNewPassword,
        name: AppRoutes.createNewPassword, // Added name for consistency
        builder: (context, state) {
          // final email = state.extra as String?; // Email might not be strictly needed here if session from OTP handles auth context
          return const CreateNewPasswordScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.register,
        builder: (context, state) => const RegisterWidget(),
        routes: [
          GoRoute(
            path: 'getting-to-know',
            name: AppRoutes.registerGettingToKnow,
            builder: (context, state) => const RegisterGettingToKnowScreen(),
          ),
          GoRoute(
            path: 'set-goals',
            name: AppRoutes.registerSetGoals,
            builder: (context, state) => const RegisterSetGoalsScreen(),
          ),
          GoRoute(
            path: 'verify',
            name: AppRoutes.registerVerify,
            builder: (context, state) {
              return const reg_verify.RegisterVerificationScreen();
            },
          ),
          GoRoute(
            path: 'success',
            name: AppRoutes.registerSuccess,
            builder: (context, state) => const RegisterSuccessScreen(),
          ),
        ],
      ),
      GoRoute(
        path:
            AppRoutes
                .workoutMyTemplates, // Add route for MyWorkoutTemplatesScreen
        builder: (context, state) => const MyWorkoutTemplatesScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutStartNew,
        builder: (context, state) => const StartNewWorkoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutStartFromTemplate,
        builder: (context, state) {
          final template = state.extra as Workout?;
          return StartWorkoutFromTemplateScreen(workout: template!);
        },
      ),
      GoRoute(
        path: AppRoutes.workoutAddExercise,
        builder: (context, state) => const AddExerciseScreen(),
      ),
      // Add the new route for Exercise Details
      GoRoute(
        path: AppRoutes.exerciseDetails, // Use the constant from AppRoutes
        builder: (context, state) {
          final exercise = state.extra as Exercise?;
          if (exercise == null) {
            // Handle error case: navigate back or show an error screen
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Error: Exercise data missing.')),
            );
          }
          // Provide the required heroTag
          return ExerciseDetailsScreen(
            exercise: exercise,
            // Example heroTag, ensure it's unique if needed across screens
            heroTag: 'exercise_image_${exercise.id}',
          );
        },
      ),
      // ADDED: Route for Workout Details Screen
      GoRoute(
        path: AppRoutes.workoutDetails,
        builder: (context, state) {
          final workout = state.extra as Workout?;
          if (workout == null) {
            // Handle error case: navigate back or show an error screen
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Error: Workout data missing.')),
            );
          }
          return WorkoutDetailsScreen(workout: workout);
        },
      ),
      GoRoute(
        path: AppRoutes.workoutComplete,
        builder: (context, state) {
          // Extract the map from extra
          final extraData = state.extra as Map<String, dynamic>?;
          final workout = extraData?['workout'] as Workout?;
          final detailedExercises =
              extraData?['detailedExercises'] as List<Exercise>?;

          if (workout == null || detailedExercises == null) {
            // Handle error case: navigate back or show an error screen
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('Error: Workout data missing or incomplete.'),
              ),
            );
          }

          // Pass both workout and detailedExercises to the screen
          return WorkoutCompleteScreen(
            workout: workout,
            detailedExercises: detailedExercises,
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
      // Add route for viewing a single photo
      GoRoute(
        path: AppRoutes.progressViewPhoto,
        builder: (context, state) {
          // Extract the index passed as an extra parameter
          final initialIndex = state.extra as int?;
          return ViewProgressPhotosWidget(initialIndex: initialIndex);
        },
      ),
      // Add route for comparing photos
      GoRoute(
        path: AppRoutes.progressPhotoCompare,
        builder: (context, state) => const CompareProgressPhotosWidget(),
      ),
      // Add the new route for Progress Details
      GoRoute(
        path: AppRoutes.progressDetails,
        builder: (context, state) => const ProgressDetailsScreen(),
      ),
      // ADDED: Route for Notifications Screen
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      // ADDED: Route for Notification Details Screen
      GoRoute(
        path: AppRoutes.notificationDetails,
        builder:
            (context, state) => NotificationDetailsScreen(
          notificationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileHistory,
        builder: (context, state) => const WorkoutHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileContact,
        builder: (context, state) => const ContactUsWidget(),
      ),
      GoRoute(
        path: AppRoutes.profilePrivacy,
        builder: (context, state) => const PrivacyPolicyWidget(),
      ),
      // New Booking Flow
      GoRoute(
        path: AppRoutes.activateGymPass,
        builder: (context, state) => const ActivateGymPassScreen(),
      ),
      GoRoute(
        path: AppRoutes.selectSession,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Select Session Screen - Coming Soon')),
        ),
      ),
      GoRoute(
        path: AppRoutes.reviewBooking,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Review Booking Screen - Coming Soon')),
        ),
      ),
      GoRoute(
        path: AppRoutes.bookingSuccess,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Booking Success Screen - Coming Soon')),
        ),
      ),
      GoRoute(
        path: AppRoutes.bookingDetails,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Booking Details Screen - Coming Soon')),
        ),
      ),
      // Legacy booking routes (to be removed after migration)
      GoRoute(
        path: AppRoutes.booking,
        builder: (context, state) => const BookingScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookings,
        builder: (context, state) => const MyBookingsWidget(),
      ),
      GoRoute(
        path: AppRoutes.recommendedWorkouts,
        builder: (context, state) => const RecommendedWorkoutsScreen(),
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
            builder: (context, state) => const WorkoutScreen(),
          ),
          GoRoute(
            path: AppRoutes.progress,
            builder:
                (context, state) =>
                    const ProgressScreen(), // Corrected widget name
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
