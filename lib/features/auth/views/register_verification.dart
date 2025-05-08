import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import '../controllers/registration_controller.dart';
import '../controllers/verify_email_controller.dart'; // Import verification logic
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../../../widgets/loading_indicator.dart'; // Import LoadingIndicator
import 'package:pinput/pinput.dart';
// import 'package:solar_icons/solar_icons.dart'; // No longer used in this UI

class RegisterVerificationScreen extends ConsumerStatefulWidget {
  const RegisterVerificationScreen({super.key});

  @override
  ConsumerState<RegisterVerificationScreen> createState() =>
      _RegisterVerificationScreenState();
}

class _RegisterVerificationScreenState
    extends ConsumerState<RegisterVerificationScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController pinCodeController = TextEditingController();
  final FocusNode pinCodeFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    pinCodeController.dispose();
    pinCodeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyAndRegister() async {
    FocusScope.of(context).unfocus();
    if (pinCodeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit code.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final registrationNotifier = ref.read(registrationProvider.notifier);
    final registrationState = ref.read(registrationProvider);

    try {
      final AuthResponse verificationResponse = await verifyEmailWithToken(
        registrationState.email,
        pinCodeController.text,
      );

      final userId = verificationResponse.user?.id;
      if (userId == null) {
        throw Exception('Verification succeeded but user ID is missing.');
      }

      await registrationNotifier.insertUserProfile(userId);

      if (mounted) {
        context.goNamed(AppRoutes.registerSuccess);
      }
    } on AuthException catch (e) {
      if (mounted) {
        pinCodeController.clear();
        pinCodeFocusNode.requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification Error: ${e.message}'),
            backgroundColor: HeronFitTheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        pinCodeController.clear();
        pinCodeFocusNode.requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    FocusScope.of(context).unfocus();
    final email = ref.read(registrationProvider).email;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email address not found to resend code.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      if (mounted) {
        pinCodeController.clear();
        pinCodeFocusNode.requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code resent to your email.'),
            backgroundColor: HeronFitTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error resending code: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(registrationProvider).email;

    final defaultPinTheme = PinTheme(
      width: 48, // Slightly smaller to fit 6 across comfortably with spacing
      height: 52,
      textStyle: HeronFitTheme.textTheme.headlineSmall?.copyWith(
        color: HeronFitTheme.textPrimary,
        fontWeight: FontWeight.bold, // Make digits bold
      ),
      decoration: BoxDecoration(
        color: HeronFitTheme.bgSecondary, // Light purple from Figma
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: HeronFitTheme.primary, width: 1.5),
      borderRadius: BorderRadius.circular(12),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: HeronFitTheme.bgSecondary, // Keep same background on submit
      ),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: HeronFitTheme.error, width: 1),
      color: HeronFitTheme.bgLight, // Lighter background for error state
    );

    return Scaffold(
      key: scaffoldKey,
      // AppBar removed
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 32.0,
          ), // Consistent padding
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content vertically
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                        ), // Adjusted padding
                        child: Image.asset(
                          'assets/images/register_email_sent.webp', // Placeholder - ensure this path is correct
                          fit: BoxFit.cover,
                          height: 300, // Adjusted height
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Email Sent!', // Updated title
                        textAlign: TextAlign.center,
                        style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                          color: HeronFitTheme.primary,
                          // fontWeight is handled by theme (ClashDisplay)
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                              color: HeronFitTheme.textSecondary,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'A 6-digit verification code has been sent to ',
                              ),
                              TextSpan(
                                text:
                                    email.isNotEmpty
                                        ? email
                                        : 'your email', // Display actual email
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: HeronFitTheme.primary, // Email color
                                ),
                              ),
                              const TextSpan(
                                text:
                                    '. Please enter it below to confirm your account and begin your HeronFit journey.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Pinput(
                        length: 6,
                        controller: pinCodeController,
                        focusNode: pinCodeFocusNode,
                        autofocus: true,
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) {
                          if (!_isLoading) _verifyAndRegister();
                        },
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        errorPinTheme: errorPinTheme,
                        separatorBuilder:
                            (index) => const SizedBox(
                              width: 8,
                            ), // Spacing between pins
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: true,
                        cursor: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 9),
                              width: 22,
                              height: 1.5,
                              color: HeronFitTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Buttons at the bottom
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: LoadingIndicator(),
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : _resendCode,
                      child: Text(
                        'Resend Code',
                        style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          color: HeronFitTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: _verifyAndRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HeronFitTheme.primary,
                        foregroundColor: HeronFitTheme.textWhite,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        textStyle: HeronFitTheme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Confirm'),
                    ),
                    const SizedBox(height: 4), // Decreased from 8
                    TextButton(
                      onPressed: () {
                        // Navigate back to register screen allowing email change
                        // Consider clearing partially entered registration data or specific fields
                        ref
                            .read(registrationProvider.notifier)
                            .updatePassword(''); // Clear password for safety
                        context.go(
                          AppRoutes.register,
                        ); // Go back to register to change email
                      },
                      child: Text(
                        'Change Email',
                        style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          color: HeronFitTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
