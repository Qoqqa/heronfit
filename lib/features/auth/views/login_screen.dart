import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heronfit/core/router/app_routes.dart';
import '../../../core/theme.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../widgets/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static String routePath = AppRoutes.login;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        if (!mounted) return;
        context.go(AppRoutes.home);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
            backgroundColor: HeronFitTheme.error,
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Error: ${e.message}'),
          backgroundColor: HeronFitTheme.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: HeronFitTheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Great To See You Again',
                        textAlign: TextAlign.center,
                        style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: HeronFitTheme.primary,
                        ),
                      ),
                      // const SizedBox(height: 8),
                      Text(
                        "Log In To Continue Your Fitness Journey.",
                        textAlign: TextAlign.center,
                        style: HeronFitTheme.textTheme.labelLarge?.copyWith(
                          color: HeronFitTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 48),

                      TextFormField(
                        controller: _emailController,
                        focusNode: emailFocusNode,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
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

                      TextFormField(
                        controller: _passwordController,
                        focusNode: passwordFocusNode,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        autofillHints: const [AutofillHints.password],
                        obscureText: !_passwordVisible,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _isLoading ? null : _signIn(),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(
                            SolarIconsOutline.lockPassword,
                            color: HeronFitTheme.textMuted,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? SolarIconsOutline.eye
                                  : SolarIconsOutline.eyeClosed,
                              color: HeronFitTheme.textMuted,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
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
                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            context.push(AppRoutes.requestOtp);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot your password?',
                            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                              color: HeronFitTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 64),

                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: LoadingIndicator(),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: _signIn,
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
                          child: const Text('Log In'),
                        ),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: () {
                          context.push(AppRoutes.register);
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                              color: HeronFitTheme.primary,
                            ),
                            children: [
                              const TextSpan(text: 'New to HeronFit? '),
                              TextSpan(
                                text: 'Register',
                                style: HeronFitTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                      color: HeronFitTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        context.push(AppRoutes.register);
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
