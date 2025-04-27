import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import '../controllers/registration_controller.dart';

class RegisterSuccessScreen extends ConsumerWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the user's first name for the welcome message
    final firstName = ref.watch(registrationProvider).firstName;
    final welcomeMessage =
        firstName.isNotEmpty ? 'Welcome, $firstName!' : 'Welcome!';

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: HeronFitTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.celebration_outlined, // Placeholder
                          color: HeronFitTheme.primary,
                          size: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      welcomeMessage,
                      style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                        color: HeronFitTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'re now part of the HeronFit community. Let\'s achieve your fitness goals together.',
                      style: HeronFitTheme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Reset the registration state before navigating home
                  ref.read(registrationProvider.notifier).reset();
                  // Use context.go to replace the entire navigation stack with home
                  context.go(AppRoutes.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HeronFitTheme.primaryDark,
                  foregroundColor: HeronFitTheme.bgLight,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Let's Go!",
                  style: HeronFitTheme.textTheme.titleSmall?.copyWith(
                    color: HeronFitTheme.bgLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
