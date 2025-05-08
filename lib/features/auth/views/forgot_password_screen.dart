import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart'; // Assuming theme.dart is in lib/core/
import 'package:heronfit/features/auth/controllers/forgot_password_controller.dart';
// TODO: Import your actual image asset if you have one, or use a placeholder
// import 'package:flutter_svg/flutter_svg.dart'; // Example for SVG

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  void _showCheckEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Column(
            children: [
              // TODO: Replace with your actual image asset for the dialog
              const Icon(
                Icons.email_outlined,
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
            'Password reset email sent! Please check your inbox for instructions.',
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
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Make button wide
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Okay!',
                style: HeronFitTheme.textTheme.labelLarge?.copyWith(
                  color: HeronFitTheme.textWhite,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(
                  context,
                ).pop(); // Go back from ForgotPasswordScreen (e.g., to Login)
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

    // Listen to the controller state
    ref.listen<ForgotPasswordState>(forgotPasswordControllerProvider, (
      previous,
      next,
    ) {
      if (next is ForgotPasswordSuccess) {
        _showCheckEmailDialog(context);
      } else if (next is ForgotPasswordError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: HeronFitTheme.error,
          ),
        );
      }
    });

    final forgotPasswordState = ref.watch(forgotPasswordControllerProvider);

    // TODO: Replace with your actual image asset or a more suitable placeholder
    Widget illustration = Container(
      height: 180, // Adjusted height
      alignment: Alignment.center,
      child: const Icon(
        Icons.lock_reset,
        size: 100,
        color: HeronFitTheme.primary,
      ), // Placeholder
    );

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: HeronFitTheme.textTheme.titleLarge?.copyWith(
            color: HeronFitTheme.textWhite,
          ),
        ),
        backgroundColor: HeronFitTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HeronFitTheme.textWhite),
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
              const SizedBox(height: 24), // Adjusted spacing
              Text(
                'Having trouble logging in? No problem! Enter your email address, and we\'ll send you a link to reset your password.',
                style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                  color: HeronFitTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: HeronFitTheme.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Slightly more rounded
                    borderSide: BorderSide(
                      color: HeronFitTheme.textMuted.withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: HeronFitTheme.textMuted.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: HeronFitTheme.primary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor:
                      HeronFitTheme
                          .bgLight, // Or Colors.white if preferred against bgLight
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ), // Added padding for this text
                child: Text(
                  'If an account with this email exists, you\'ll receive an email with instructions. Please check your inbox.',
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ), // Increased padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Consistent rounding
                  ),
                  textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                    color: HeronFitTheme.textWhite,
                  ),
                ),
                onPressed:
                    forgotPasswordState is ForgotPasswordLoading
                        ? null // Disable button when loading
                        : () {
                          if (formKey.currentState!.validate()) {
                            ref
                                .read(forgotPasswordControllerProvider.notifier)
                                .sendResetLink(emailController.text.trim());
                          }
                        },
                child:
                    forgotPasswordState is ForgotPasswordLoading
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
                          'Send Reset Link',
                          style: HeronFitTheme.textTheme.labelLarge?.copyWith(
                            color: HeronFitTheme.textWhite,
                          ),
                        ),
              ),
              const SizedBox(height: 16),
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
                  style: HeronFitTheme.textTheme.labelLarge?.copyWith(
                    color: HeronFitTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
