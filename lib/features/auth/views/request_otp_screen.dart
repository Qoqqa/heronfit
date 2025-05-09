import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // For navigation
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/core/router/app_routes.dart'; // For new routes
import 'package:heronfit/features/auth/controllers/password_recovery_controller.dart';
import 'package:solar_icons/solar_icons.dart'; // Import Solar Icons

class RequestOtpScreen extends ConsumerWidget {
  const RequestOtpScreen({super.key});

  void _showCheckEmailDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Column(
            children: [
              const Icon(
                SolarIconsOutline.mailbox,
                color: HeronFitTheme.primary,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Check Your Email',
                style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                  color: HeronFitTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            'A verification code has been sent to $email. Please check your inbox for instructions.',
            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
              color: HeronFitTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HeronFitTheme.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Okay',
                style: HeronFitTheme.textTheme.labelLarge?.copyWith(
                  color: HeronFitTheme.textWhite,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                // Navigate to EnterOtpScreen, passing the email
                context.pushNamed(AppRoutes.enterOtp, extra: email);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();

    ref.listen<PasswordRecoveryState>(passwordRecoveryControllerProvider, (
      previous,
      next,
    ) {
      final currentEmail = emailController.text.trim();
      if (next is PasswordRecoveryOtpSent) {
        _showCheckEmailDialog(context, currentEmail);
      } else if (next is PasswordRecoveryError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: HeronFitTheme.error,
          ),
        );
      }
    });

    final passwordRecoveryState = ref.watch(passwordRecoveryControllerProvider);

    Widget illustration = SizedBox(
      height: 300, // Adjusted height for better visual balance
      width: double.infinity,
      child: Image.asset(
        'assets/images/password_recovery.webp', // Use the specified image
        fit: BoxFit.contain, // Ensure the image fits well
      ),
    );

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Password Recovery',
          style: HeronFitTheme.textTheme.titleLarge?.copyWith(
            color: HeronFitTheme.textWhite,
          ),
        ),
        backgroundColor: HeronFitTheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            SolarIconsOutline.altArrowLeft,
            color: HeronFitTheme.textWhite,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              illustration,
              const SizedBox(height: 30), // Adjusted spacing
              Text(
                'Enter your email, and we\'ll send a code to help you reset your password.', // Updated text
                style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                  color: HeronFitTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24), // Adjusted spacing
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(
                    SolarIconsOutline.letter,
                    color: HeronFitTheme.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: HeronFitTheme.primary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: HeronFitTheme.bgSecondary,
                  // Light lavender background
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  labelStyle: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                    color: HeronFitTheme.textSecondary,
                  ),
                  hintStyle: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                    color: HeronFitTheme.textMuted,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'If an account with this email exists, you\'ll receive a verification code. Please check your inbox.',
                  style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                    color: HeronFitTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HeronFitTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                    color: HeronFitTheme.textWhite,
                  ),
                ),
                onPressed:
                    passwordRecoveryState is PasswordRecoveryLoading
                        ? null
                        : () {
                          if (formKey.currentState!.validate()) {
                            ref
                                .read(
                                  passwordRecoveryControllerProvider.notifier,
                                )
                                .sendRecoveryOtp(emailController.text.trim());
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
                          'Send Code', // Updated button text
                          style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                            color: HeronFitTheme.textWhite,
                          ),
                        ),
              ),
              const SizedBox(height: 8),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(color: HeronFitTheme.primary),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Back to Login',
                  style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                    color: HeronFitTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
