import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/features/auth/controllers/password_recovery_controller.dart';
import 'package:pinput/pinput.dart';
import 'package:solar_icons/solar_icons.dart';

class EnterOtpScreen extends ConsumerStatefulWidget {
  final String email;
  const EnterOtpScreen({super.key, required this.email});

  @override
  ConsumerState<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends ConsumerState<EnterOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
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
        _otpController.clear();
        _otpFocusNode.requestFocus();
      }
    });

    final passwordRecoveryState = ref.watch(passwordRecoveryControllerProvider);

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: HeronFitTheme.textTheme.headlineSmall?.copyWith(
        color: HeronFitTheme.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: HeronFitTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HeronFitTheme.primary.withOpacity(0.2)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: HeronFitTheme.primary, width: 1.5),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: HeronFitTheme.error, width: 1.5),
      ),
    );
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: HeronFitTheme.success, width: 1.5),
      ),
    );

    Widget illustration = SizedBox(
      height: 300,
      width: double.infinity,
      child: Image.asset('assets/images/enter_code.webp', fit: BoxFit.contain),
    );

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: HeronFitTheme.primary,
            size: 30,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Enter Verification Code',
          style: HeronFitTheme.textTheme.titleLarge?.copyWith(
            color: HeronFitTheme.primary,
          ),
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
              illustration,
              const SizedBox(height: 30),
              Text(
                'Please enter the 6-digit verification code we\'ve sent to ${widget.email}.',
                style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                  color: HeronFitTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Pinput(
                controller: _otpController,
                focusNode: _otpFocusNode,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
                submittedPinTheme: submittedPinTheme,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  if (value.length < 6) {
                    return 'OTP must be 6 digits';
                  }
                  return null;
                },
                onCompleted: (pin) {
                  if (_formKey.currentState!.validate()) {
                    ref
                        .read(passwordRecoveryControllerProvider.notifier)
                        .verifyRecoveryOtp(pin);
                  }
                },
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
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
                    passwordRecoveryState is PasswordRecoveryLoading
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
                          'Verify Code',
                          style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                            color: HeronFitTheme.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed:
                    passwordRecoveryState is PasswordRecoveryLoading
                        ? null
                        : _resendOtp,
                child: Text(
                  'Resend Code',
                  style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                    color: HeronFitTheme.primary,
                    fontWeight: FontWeight.w600,
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
