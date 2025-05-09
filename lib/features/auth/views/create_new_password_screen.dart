import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/features/auth/controllers/password_recovery_controller.dart';
import 'package:solar_icons/solar_icons.dart';

class CreateNewPasswordScreen extends ConsumerStatefulWidget {
  // final String email; // May not be needed if session is established
  const CreateNewPasswordScreen({super.key /*, required this.email*/});

  @override
  ConsumerState<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState
    extends ConsumerState<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showPasswordUpdatedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Column(
            children: [
              const Icon(
                SolarIconsBold.confetti,
                color: HeronFitTheme.primary,
                size: 100,
              ),
              const SizedBox(height: 48),
              Text(
                'Password Updated',
                style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                  color: HeronFitTheme.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Your password has been updated successfully. Please login with your new password.',
            textAlign: TextAlign.center,
            style: HeronFitTheme.textTheme.bodyMedium,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HeronFitTheme.primary,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(
                'Login',
                style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                  color: HeronFitTheme.textWhite,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                context.go(AppRoutes.login); // Navigate to Login screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PasswordRecoveryState>(passwordRecoveryControllerProvider, (
      previous,
      next,
    ) {
      if (!mounted) return; // Add this check

      if (next is PasswordRecoveryFlowComplete) {
        _showPasswordUpdatedDialog(context);
      } else if (next is PasswordRecoveryError &&
          next.stage == RecoveryStage.passwordUpdate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: HeronFitTheme.error,
          ),
        );
      }
    });

    final passwordRecoveryState = ref.watch(passwordRecoveryControllerProvider);

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Create New Password',
          style: HeronFitTheme.textTheme.titleLarge?.copyWith(
            color: HeronFitTheme.primary,
          ),
        ),
        backgroundColor: HeronFitTheme.bgLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            SolarIconsOutline.altArrowLeft,
            color: HeronFitTheme.primary,
          ),
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
              Image.asset(
                'assets/images/create_new_password.webp',
                height: 300,
              ),
              const SizedBox(height: 20),
              Text(
                'Your new password needs to be strong! Make sure it\'s at least 8 characters long and includes a combination of letters, numbers, and symbols for better security.',
                style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                  color: HeronFitTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_newPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter your new password',
                  prefixIcon: const Icon(
                    SolarIconsOutline.lockPassword,
                    color: HeronFitTheme.textMuted,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _newPasswordVisible
                          ? SolarIconsOutline.eyeClosed
                          : SolarIconsOutline.eye,
                      color: HeronFitTheme.textMuted,
                    ),
                    onPressed:
                        () => setState(
                          () => _newPasswordVisible = !_newPasswordVisible,
                        ),
                  ),
                  border: OutlineInputBorder(
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter a new password';
                  if (value.length < 8)
                    return 'Password must be at least 8 characters';
                  // Add more complex validation if needed (e.g., regex for complexity)
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  hintText: 'Re-enter your new password',
                  prefixIcon: const Icon(
                    SolarIconsOutline.lockPassword,
                    color: HeronFitTheme.textMuted,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible
                          ? SolarIconsOutline.eyeClosed
                          : SolarIconsOutline.eye,
                      color: HeronFitTheme.textMuted,
                    ),
                    onPressed:
                        () => setState(
                          () =>
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible,
                        ),
                  ),
                  border: OutlineInputBorder(
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please confirm your new password';
                  if (value != _newPasswordController.text)
                    return 'Passwords do not match';
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
                          // Add null check for _formKey.currentState
                          if (_formKey.currentState != null &&
                              _formKey.currentState!.validate()) {
                            ref
                                .read(
                                  passwordRecoveryControllerProvider.notifier,
                                )
                                .updateUserPassword(
                                  _newPasswordController.text.trim(),
                                );
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
                          'Set New Password',
                          style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                            color: HeronFitTheme.textWhite,
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
