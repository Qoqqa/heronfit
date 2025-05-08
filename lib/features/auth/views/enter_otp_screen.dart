import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/features/auth/controllers/password_recovery_controller.dart';

class EnterOtpScreen extends ConsumerStatefulWidget {
  final String email;
  const EnterOtpScreen({super.key, required this.email});

  @override
  ConsumerState<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends ConsumerState<EnterOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _resendOtp() {
    ref
        .read(passwordRecoveryControllerProvider.notifier)
        .sendRecoveryOtp(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PasswordRecoveryState>(passwordRecoveryControllerProvider, (
      previous,
      next,
    ) {
      if (next is PasswordRecoveryOtpVerificationSuccess) {
        context.pushReplacementNamed(
          AppRoutes.createNewPassword,
          extra: widget.email,
        );
      } else if (next is PasswordRecoveryError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error (${next.stage.name}): ${next.message}"),
            backgroundColor: HeronFitTheme.error,
          ),
        );
      } else if (next is PasswordRecoveryOtpSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification code sent to ${widget.email}')),
        );
      }
    });

    final passwordRecoveryState = ref.watch(passwordRecoveryControllerProvider);

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Enter Verification Code',
          style: HeronFitTheme.textTheme.titleLarge?.copyWith(
            color: HeronFitTheme.textWhite,
          ),
        ),
        backgroundColor: HeronFitTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HeronFitTheme.textWhite),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                'We\'ve sent a verification code to your email address: ${widget.email}. Please enter the code below.',
                style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                  color: HeronFitTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  hintText: 'Enter the 6-digit code',
                  prefixIcon: const Icon(
                    Icons.password_rounded,
                    color: HeronFitTheme.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: HeronFitTheme.primary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: HeronFitTheme.bgLight,
                ),
                keyboardType: TextInputType.number,
                maxLength: 6, // Assuming OTP is 6 digits
                textAlign: TextAlign.center,
                style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                  letterSpacing: 8,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  if (value.length < 6) {
                    return 'OTP must be 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HeronFitTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed:
                    passwordRecoveryState is PasswordRecoveryLoading
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            ref
                                .read(
                                  passwordRecoveryControllerProvider.notifier,
                                )
                                .verifyRecoveryOtp(_otpController.text.trim());
                          }
                        },
                child:
                    passwordRecoveryState is PasswordRecoveryLoading &&
                            (passwordRecoveryState
                                    as PasswordRecoveryLoading) !=
                                PasswordRecoveryInitial() // More specific loading check if needed
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          'Verify',
                          style: HeronFitTheme.textTheme.labelLarge?.copyWith(
                            color: HeronFitTheme.textWhite,
                          ),
                        ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed:
                    passwordRecoveryState is PasswordRecoveryLoading
                        ? null
                        : _resendOtp,
                child: Text(
                  'Resend Code',
                  style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                    color: HeronFitTheme.primary,
                    fontWeight: FontWeight.bold,
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
