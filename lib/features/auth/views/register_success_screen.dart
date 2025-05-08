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
    final firstName = ref.watch(registrationProvider).firstName;
    final welcomeMessage =
        firstName.isNotEmpty ? 'Welcome, $firstName!' : 'Welcome!';

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        child: Padding(
          // Overall padding for the screen content.
          // Vertical padding helps define top/bottom margins.
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceEvenly, // Distributes children vertically
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Ensures button stretches
            children: [
              // Image Block - Top
              Container(
                height: 400,
                width: double.infinity,
                // width: double.infinity, // Not needed due to CrossAxisAlignment.stretch
                child: Image.asset(
                  'assets/images/register_success.webp',
                  fit: BoxFit.cover, // Ensures the whole image is visible
                ),
              ),

              // Text Block - Middle
              Column(
                mainAxisSize: MainAxisSize.min, // Keeps this text block compact
                children: [
                  Text(
                    welcomeMessage,
                    textAlign: TextAlign.center,
                    style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                      color: HeronFitTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8), // Tightly packed space
                  Padding(
                    // Horizontal padding for the description text if it's long
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'You\'re now part of the HeronFit community. Let\'s achieve your fitness goals together.',
                      textAlign: TextAlign.center,
                      style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                        color: HeronFitTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              // Button Block - Bottom
              ElevatedButton(
                onPressed: () {
                  ref.read(registrationProvider.notifier).reset();
                  context.go(AppRoutes.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HeronFitTheme.primary,
                  foregroundColor: HeronFitTheme.bgLight,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: HeronFitTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text("Let\'s Get Started"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
