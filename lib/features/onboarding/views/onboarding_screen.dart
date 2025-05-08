import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/router/app_routes.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({super.key});

  static String routePath = AppRoutes.onboarding;

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: HeronFitTheme.bgLight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48.0),

                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 36.0,
                    child: Image.asset(
                      'assets/images/logotype_heronfit.webp',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 48.0),

                Container(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/onboarding_hero.webp',
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome to HeronFit',
                      textAlign: TextAlign.center,
                      style: HeronFitTheme.textTheme.headlineMedium?.copyWith(
                        color: HeronFitTheme.primary,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    Text(
                      'Your Fitness Journey Starts Here',
                      textAlign: TextAlign.center,
                      style: HeronFitTheme.textTheme.bodyLarge?.copyWith(
                        color: HeronFitTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.register);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52.0),
                        backgroundColor: HeronFitTheme.primary,
                        foregroundColor: HeronFitTheme.bgLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        textStyle: HeronFitTheme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Get Started'),
                    ),
                    const SizedBox(height: 24.0),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        context.push(AppRoutes.login);
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                            color: HeronFitTheme.primary,
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Log in',
                              style: HeronFitTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                    color: HeronFitTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    // decoration: TextDecoration.underline,
                                  ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      context.push(AppRoutes.login);
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
