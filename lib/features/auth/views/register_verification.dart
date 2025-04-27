import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:pin_code_fields/pin_code_fields.dart' hide PinTheme;
import '../controllers/registration_controller.dart';
import '../controllers/verify_email_controller.dart'; // Import verification logic
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../../../widgets/loading_indicator.dart'; // Import LoadingIndicator
import 'package:pinput/pinput.dart';

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
  String _pinCode = '';
  bool _isLoading = false;

  @override
  void dispose() {
    pinCodeController.dispose();
    pinCodeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyAndRegister() async {
    if (_pinCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit code.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final registrationNotifier = ref.read(registrationProvider.notifier);
    final registrationState = ref.read(registrationProvider);

    try {
      // Step 1: Verify the email OTP token with Supabase
      final AuthResponse verificationResponse = await verifyEmailWithToken(
        registrationState.email,
        _pinCode,
      );

      // If verification is successful, we get the user ID
      final userId = verificationResponse.user?.id;
      if (userId == null) {
        // Should ideally not happen if verifyEmailWithToken succeeded based on our checks
        throw Exception('Verification succeeded but user ID is missing.');
      }

      // Step 2: Insert the user profile data using the obtained user ID
      await registrationNotifier.insertUserProfile(userId);

      // Step 3: Navigate to the success screen
      if (mounted) {
        context.goNamed(AppRoutes.registerSuccess);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification Error: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // TODO: Implement resend code logic
  Future<void> _resendCode() async {
    final email = ref.read(registrationProvider).email;
    if (email.isEmpty) return; // Should not happen

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code resent to your email.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resending code: ${e.toString()}')),
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

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: HeronFitTheme.bgLight,
        elevation: 0,
        leading: BackButton(color: HeronFitTheme.primary),
      ),
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          0,
                          0,
                          16,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 200, // Adjusted height
                          decoration: BoxDecoration(
                            color: HeronFitTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Icon(
                              Icons
                                  .mark_email_read_outlined, // Placeholder icon
                              color: HeronFitTheme.primary,
                              size: 80,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-1, 0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            0,
                            0,
                            0,
                            8,
                          ),
                          child: Text(
                            'Almost There!',
                            textAlign: TextAlign.start,
                            style: HeronFitTheme.textTheme.headlineSmall
                                ?.copyWith(
                                  color: HeronFitTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-1, 0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Please enter the 6 digit code sent to ',
                                style: HeronFitTheme.textTheme.labelMedium
                                    ?.copyWith(
                                      color: HeronFitTheme.textPrimary,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              TextSpan(
                                text: email,
                                style: HeronFitTheme.textTheme.labelMedium
                                    ?.copyWith(
                                      color: HeronFitTheme.primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      // decoration: TextDecoration.underline, // Removed underline for clarity
                                    ),
                              ),
                              TextSpan(
                                text:
                                    ' to verify your account and start your fitness journey.',
                                style: HeronFitTheme.textTheme.labelMedium
                                    ?.copyWith(
                                      color: HeronFitTheme.textPrimary,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: Pinput(
                          length: 6,
                          controller: pinCodeController,
                          focusNode: pinCodeFocusNode,
                          autofocus: true,
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          onChanged: (value) {
                            _pinCode = value;
                          },
                          onCompleted: (pin) {
                            _pinCode = pin;
                            _verifyAndRegister(); // Trigger verification on completion
                          },
                          cursor: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 9),
                                width: 22,
                                height: 1,
                                color: HeronFitTheme.primary,
                              ),
                            ],
                          ),
                          defaultPinTheme: PinTheme(
                            width: 48,
                            height: 48,
                            textStyle: HeronFitTheme.textTheme.titleMedium,
                            decoration: BoxDecoration(
                              color: HeronFitTheme.bgSecondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 48,
                            height: 48,
                            textStyle: HeronFitTheme.textTheme.titleMedium,
                            decoration: BoxDecoration(
                              color: HeronFitTheme.bgLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: HeronFitTheme.primary),
                            ),
                          ),
                          submittedPinTheme: PinTheme(
                            width: 48,
                            height: 48,
                            textStyle: HeronFitTheme.textTheme.titleMedium
                                ?.copyWith(color: HeronFitTheme.primaryDark),
                            decoration: BoxDecoration(
                              color: HeronFitTheme.bgPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          errorPinTheme: PinTheme(
                            width: 48,
                            height: 48,
                            textStyle: HeronFitTheme.textTheme.titleMedium,
                            decoration: BoxDecoration(
                              color: HeronFitTheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: HeronFitTheme.error),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: LoadingIndicator(),
                    )
                  else ...[
                    ElevatedButton(
                      onPressed: _verifyAndRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HeronFitTheme.primaryDark,
                        foregroundColor: HeronFitTheme.bgLight,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: HeronFitTheme.textTheme.titleSmall?.copyWith(
                          color: HeronFitTheme.bgLight,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isLoading ? null : _resendCode,
                      child: Text(
                        'Resend Code',
                        style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                          color: HeronFitTheme.primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // Allow changing email - go back to register screen
                        ref.read(registrationProvider.notifier).reset();
                        context.goNamed(AppRoutes.register);
                      },
                      child: Text(
                        'Change Email',
                        style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                          color: HeronFitTheme.textMuted,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
