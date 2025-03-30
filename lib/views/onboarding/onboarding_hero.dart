import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import '../../core/theme.dart';
import '../home/home_screen.dart';
// import '../login/login_screen.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({super.key});

  static String routeName = 'Onboarding';
  static String routePath = '/onboarding';

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
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: double.infinity,
              height: 48.0,
              decoration: BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/images/logotype_heronfit.png',
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Flexible(
              child: Container(
                width: double.infinity,
                height: 400.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image:
                        Image.asset('assets/images/onboarding_hero.png').image,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          'Welcome to HeronFit',
                          textAlign: TextAlign.center,
                          style: HeronFitTheme.textTheme.headlineMedium
                              ?.copyWith(
                                color: HeronFitTheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          'Your Fitness Journey Starts Here',
                          style: HeronFitTheme.textTheme.titleSmall?.copyWith(
                            color: HeronFitTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          16.0,
                          0.0,
                          16.0,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/register',
                            ); // Navigate to RegisterWidget
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48.0),
                            backgroundColor: HeronFitTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'Get Started',
                            style: HeronFitTheme.textTheme.titleSmall?.copyWith(
                              color: HeronFitTheme.bgLight,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.of(context).pushNamed('/login');
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account?',
                                style: HeronFitTheme.textTheme.labelMedium
                                    ?.copyWith(
                                      color: HeronFitTheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              TextSpan(
                                text: ' Log In',
                                style: HeronFitTheme.textTheme.labelMedium
                                    ?.copyWith(
                                      color: HeronFitTheme.primaryDark,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(
                                          context,
                                        ).pushNamed('/login');
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
