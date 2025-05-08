import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:heronfit/core/router/app_routes.dart'; // Import routes
import '../../../core/theme.dart'; // Updated import path
// import 'login_screen.dart'; // No longer directly needed for UI elements from here
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/registration_controller.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons
import '../../../widgets/loading_indicator.dart'; // For loading state

class RegisterWidget extends ConsumerStatefulWidget {
  const RegisterWidget({super.key});

  static String routePath = AppRoutes.register; // Corrected route path

  @override
  ConsumerState<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends ConsumerState<RegisterWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _passwordVisibility = false; // Renamed for clarity
  bool _passwordConfirmVisibility = false; // Renamed for clarity
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  bool _termsAccepted = false;
  bool _isLoading = false; // Local loading state for UI

  // Controller for other fields to sync with Riverpod state if needed, or use initialValue
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with values from Riverpod state if they exist
    // This helps in cases where the user navigates back and forth
    final initialRegistrationState = ref.read(registrationProvider);
    _firstNameController.text = initialRegistrationState.firstName;
    _lastNameController.text = initialRegistrationState.lastName;
    _emailController.text = initialRegistrationState.email;
    _passwordController.text = initialRegistrationState.password;
    // Note: passwordConfirmController should not be pre-filled from state typically
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  String? _validatePasswordConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _onRegister() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions.'),
          backgroundColor: HeronFitTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update Riverpod state with current controller values before initiating sign up
      // This ensures the controller has the latest data if onChanged was used directly
      // on controllers without immediate Riverpod update (though current setup updates Riverpod on each change)
      ref
          .read(registrationProvider.notifier)
          .updateFirstName(_firstNameController.text.trim());
      ref
          .read(registrationProvider.notifier)
          .updateLastName(_lastNameController.text.trim());
      ref
          .read(registrationProvider.notifier)
          .updateEmail(_emailController.text.trim());
      ref
          .read(registrationProvider.notifier)
          .updatePassword(_passwordController.text.trim());

      await ref.read(registrationProvider.notifier).initiateSignUp();
      if (mounted) {
        // Navigate to the screen where the user can verify their email / enter OTP
        context.go(AppRoutes.registerVerify);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: HeronFitTheme.error,
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
    final registrationState = ref.watch(registrationProvider);
    final registrationNotifier = ref.read(registrationProvider.notifier);

    // Sync controllers with Riverpod state if they haven't been changed by the user
    // This helps keep them in sync if Riverpod state is updated externally, though less common for text fields
    // _firstNameController.text = registrationState.firstName; // Be cautious with this; can cause cursor jumps
    // ... similar for other controllers if absolutely necessary

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: HeronFitTheme.bgLight,
        body: SafeArea(
          top: true,
          child: Center(
            // Center content vertically
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ), // Max width for content
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center column content
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title Section
                      Text(
                        'Welcome to HeronFit',
                        textAlign: TextAlign.center,
                        style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                          color: HeronFitTheme.primary,
                          // fontWeight is handled by theme
                        ),
                      ),
                      // const SizedBox(height: 8),
                      Text(
                        'Ready to unlock your fitness potential?',
                        textAlign: TextAlign.center,
                        style: HeronFitTheme.textTheme.labelLarge?.copyWith(
                          color: HeronFitTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // First Name Field
                      TextFormField(
                        controller: _firstNameController,
                        onChanged: registrationNotifier.updateFirstName,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter your first name'
                                    : null,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'First Name',
                          prefixIcon: const Icon(
                            SolarIconsOutline.user,
                            color: HeronFitTheme.textMuted,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: HeronFitTheme.bgSecondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        style: HeronFitTheme.textTheme.bodyLarge?.copyWith(
                          color: HeronFitTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Last Name Field
                      TextFormField(
                        controller: _lastNameController,
                        onChanged: registrationNotifier.updateLastName,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter your last name'
                                    : null,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Last Name',
                          prefixIcon: const Icon(
                            SolarIconsOutline.user,
                            color: HeronFitTheme.textMuted,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: HeronFitTheme.bgSecondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        style: HeronFitTheme.textTheme.bodyLarge?.copyWith(
                          color: HeronFitTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        onChanged: registrationNotifier.updateEmail,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter your email';
                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        autofillHints: const [AutofillHints.email],
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Icon(
                            SolarIconsOutline.letter,
                            color: HeronFitTheme.textMuted,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: HeronFitTheme.bgSecondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        style: HeronFitTheme.textTheme.bodyLarge?.copyWith(
                          color: HeronFitTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        onChanged: registrationNotifier.updatePassword,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter a password';
                          if (value.length < 6)
                            return 'Password must be at least 6 characters';
                          return null;
                        },
                        autofillHints: const [AutofillHints.newPassword],
                        obscureText: !_passwordVisibility,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(
                            SolarIconsOutline.lockPassword,
                            color: HeronFitTheme.textMuted,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisibility
                                  ? SolarIconsOutline.eye
                                  : SolarIconsOutline.eyeClosed,
                              color: HeronFitTheme.textMuted,
                              size: 20,
                            ),
                            onPressed:
                                () => setState(
                                  () =>
                                      _passwordVisibility =
                                          !_passwordVisibility,
                                ),
                          ),
                          filled: true,
                          fillColor: HeronFitTheme.bgSecondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        style: HeronFitTheme.textTheme.bodyLarge?.copyWith(
                          color: HeronFitTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      TextFormField(
                        controller: _passwordConfirmController,
                        // No direct Riverpod update for confirm password; it's for validation only
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validatePasswordConfirm,
                        autofillHints: const [AutofillHints.newPassword],
                        obscureText: !_passwordConfirmVisibility,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted:
                            (_) => _isLoading ? null : _onRegister(),
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          prefixIcon: const Icon(
                            SolarIconsOutline.lockPassword,
                            color: HeronFitTheme.textMuted,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordConfirmVisibility
                                  ? SolarIconsOutline.eye
                                  : SolarIconsOutline.eyeClosed,
                              color: HeronFitTheme.textMuted,
                              size: 20,
                            ),
                            onPressed:
                                () => setState(
                                  () =>
                                      _passwordConfirmVisibility =
                                          !_passwordConfirmVisibility,
                                ),
                          ),
                          filled: true,
                          fillColor: HeronFitTheme.bgSecondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        style: HeronFitTheme.textTheme.bodyLarge?.copyWith(
                          color: HeronFitTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Terms and Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: (bool? value) {
                              setState(() {
                                _termsAccepted = value ?? false;
                              });
                            },
                            activeColor: HeronFitTheme.primary,
                            side: const BorderSide(
                              color: HeronFitTheme.textMuted,
                            ),
                            visualDensity:
                                VisualDensity.compact, // Makes checkbox smaller
                            materialTapTargetSize:
                                MaterialTapTargetSize
                                    .shrinkWrap, // Reduces tap area
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: HeronFitTheme.textTheme.bodySmall
                                    ?.copyWith(color: HeronFitTheme.textMuted),
                                children: [
                                  const TextSpan(
                                    text: 'By continuing you accept our ',
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: HeronFitTheme.textTheme.bodySmall
                                        ?.copyWith(
                                          color: HeronFitTheme.textMuted,
                                          fontWeight: FontWeight.bold,
                                          // decoration: TextDecoration.underline, // Optional: Add underline
                                        ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            context.push(
                                              AppRoutes.profilePrivacy,
                                            );
                                          },
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Terms of Use',
                                    style: HeronFitTheme.textTheme.bodySmall
                                        ?.copyWith(
                                          color: HeronFitTheme.textMuted,
                                          fontWeight: FontWeight.bold,
                                          // decoration: TextDecoration.underline, // Optional: Add underline
                                        ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            context.push(
                                              AppRoutes.profileTerms,
                                            );
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Register Button
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: LoadingIndicator(),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: _onRegister,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52.0),
                            backgroundColor: HeronFitTheme.primary,
                            foregroundColor: HeronFitTheme.textWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            textStyle: HeronFitTheme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          child: const Text('Register'),
                        ),
                      const SizedBox(height: 24),

                      // Already have an account? Login
                      InkWell(
                        onTap: () => context.go(AppRoutes.login),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                              color: HeronFitTheme.primary,
                            ),
                            children: [
                              const TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Log In',
                                style: HeronFitTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                      color: HeronFitTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap =
                                          () => context.go(AppRoutes.login),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // Bottom spacing
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
