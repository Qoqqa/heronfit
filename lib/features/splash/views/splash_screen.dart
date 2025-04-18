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
  // Flag to prevent multiple navigations
  bool _navigationScheduled = false;

  @override
  void initState() {
    super.initState();
    // Start the minimum splash duration timer
    _startSplashTimer();
  }

  void _startSplashTimer() async {
    // Minimum splash screen duration
    await Future.delayed(const Duration(seconds: 2));

    // After the delay, check the current auth state and navigate if needed
    // This handles the initial state check after the splash duration.
    // The listener below handles subsequent changes (like logout).
    if (mounted && !_navigationScheduled) {
      final currentAuthState = ref.read(authStateChangesProvider).value;
      _scheduleNavigation(currentAuthState?.session?.user);
    }
  }

  void _scheduleNavigation(User? user) {
    // Ensure navigation only happens once and the widget is still mounted
    if (!mounted || _navigationScheduled) return;

    _navigationScheduled = true; // Set flag to prevent further navigations

    // Schedule navigation for after the current build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Double-check mounted status after the async gap
      if (!mounted) return;

      if (user != null) {
        debugPrint(
          'User found. Navigating to Home... User ID: ${user.id} (PostFrame)',
        );
        // Use go for navigating within the main app structure
        context.go(AppRoutes.home);
      } else {
        debugPrint('No user found. Navigating to Onboarding... (PostFrame)');
        // Use pushReplacement to replace splash screen
        context.pushReplacement(AppRoutes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use ref.listen to react to auth state changes for side effects (navigation)
    ref.listen<AsyncValue<AuthState>>(authStateChangesProvider, (
      previous,
      next,
    ) {
      // Only navigate if the state has actually changed and we haven't scheduled yet
      // Check specifically for the presence/absence of a user session
      final previousUser = previous?.value?.session?.user;
      final nextUser = next.value?.session?.user;

      if (previousUser?.id != nextUser?.id) {
        // Reset navigation flag if auth state changes significantly
        // This allows navigation if user logs out then logs back in quickly,
        // though the splash screen might not be visible then.
        _navigationScheduled = false;
        _scheduleNavigation(nextUser);
      }
    });

    // UI remains the same
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
      ),
    );
  }
}
