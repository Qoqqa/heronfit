import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme.dart';
import '../../auth/controllers/auth_controller.dart';

class SplashScreenWidget extends ConsumerStatefulWidget {
  const SplashScreenWidget({super.key});

  @override
  ConsumerState<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends ConsumerState<SplashScreenWidget> {
  bool _navigationScheduled = false;
  bool _minimumTimeElapsed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start the minimum splash duration timer
    _timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _minimumTimeElapsed = true;
      });
      // Trigger navigation check *after* min time if auth state is already known
      _checkAndNavigateIfNeeded(ref.read(authStateChangesProvider));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkAndNavigateIfNeeded(AsyncValue<AuthState> authState) {
    // Navigate only if minimum time has passed AND auth state is resolved (not loading)
    if (_minimumTimeElapsed && !_navigationScheduled && !authState.isLoading) {
      _scheduleNavigation(authState.value?.session?.user);
    }
  }

  void _scheduleNavigation(User? user) {
    if (!mounted || _navigationScheduled) return;
    _navigationScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetRoute = user != null ? AppRoutes.home : AppRoutes.onboarding;
      final message =
          user != null
              ? 'User found. Navigating to Home... User ID: ${user.id} (PostFrame)'
              : 'No user found. Navigating to Onboarding... (PostFrame)';
      debugPrint(message);

      // Use pushReplacement to avoid splash screen in back stack for onboarding
      // Use go to reset stack for home
      if (user != null) {
        context.go(targetRoute);
      } else {
        context.pushReplacement(targetRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen<AsyncValue<AuthState>>(authStateChangesProvider, (
      previous,
      next,
    ) {
      // Trigger navigation check whenever auth state changes (and is resolved)
      _checkAndNavigateIfNeeded(next);
    });

    // UI remains the same (you can add a loading indicator if desired)
    return Scaffold(
      backgroundColor: HeronFitTheme.primary,
      body: SafeArea(
        top: true,
        child: Align(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/logo_heronfit.png',
                              width: double.infinity,
                              height: 100.0,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          'HeronFit',
                          style: HeronFitTheme.textTheme.displayMedium
                              ?.copyWith(color: HeronFitTheme.bgLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
