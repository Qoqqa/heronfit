import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:heronfit/core/router/app_routes.dart'; // Import routes
import '../../../core/theme.dart'; // Updated import path
import 'login_screen.dart'; // Import the LoginWidget
import 'registerverification_widget.dart'; // Ensure this file defines the RegisterVerificationWidget class

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  static String routePath = '/register';

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController firstNameTextController = TextEditingController();
  final TextEditingController lastNameTextController = TextEditingController();
  final TextEditingController emailAddressTextController =
      TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController passwordConfirmTextController =
      TextEditingController();

  bool passwordVisibility = false;
  bool passwordConfirmVisibility = false;

  @override
  void dispose() {
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    emailAddressTextController.dispose();
    passwordTextController.dispose();
    passwordConfirmTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: HeronFitTheme.bgLight,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0, 0),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Welcome to HeronFit',
                        style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                          color: HeronFitTheme.primary,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Text(
                        'Ready to Begin?',
                        style: HeronFitTheme.textTheme.headlineLarge?.copyWith(
                          color: HeronFitTheme.primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Form(
                          autovalidateMode: AutovalidateMode.always,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  0,
                                  0,
                                  0,
                                  16,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: firstNameTextController,
                                    autofocus: true,
                                    autofillHints: [AutofillHints.name],
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'First Name',
                                      labelStyle: HeronFitTheme
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(letterSpacing: 0.0),
                                      alignLabelWithHint: false,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.primaryDark,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.error,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.error,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: HeronFitTheme.bgSecondary,
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: HeronFitTheme.textMuted,
                                        size: 24,
                                      ),
                                    ),
                                    style: HeronFitTheme.textTheme.labelMedium
                                        ?.copyWith(letterSpacing: 0.0),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  0,
                                  0,
                                  0,
                                  16,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: lastNameTextController,
                                    autofocus: true,
                                    autofillHints: [AutofillHints.name],
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'Last Name',
                                      labelStyle: HeronFitTheme
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(letterSpacing: 0.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.primaryDark,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.error,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.error,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: HeronFitTheme.bgSecondary,
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: HeronFitTheme.textMuted,
                                        size: 24,
                                      ),
                                    ),
                                    style: HeronFitTheme.textTheme.labelMedium
                                        ?.copyWith(letterSpacing: 0.0),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  0,
                                  0,
                                  0,
                                  16,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: emailAddressTextController,
                                    autofocus: true,
                                    autofillHints: [AutofillHints.email],
                                    textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: HeronFitTheme
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(letterSpacing: 0.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.primaryDark,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.error,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.error,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: HeronFitTheme.bgSecondary,
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: HeronFitTheme.textMuted,
                                      ),
                                    ),
                                    style: HeronFitTheme.textTheme.labelMedium
                                        ?.copyWith(letterSpacing: 0.0),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  0,
                                  0,
                                  0,
                                  16,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: passwordTextController,
                                    autofocus: true,
                                    autofillHints: [AutofillHints.password],
                                    textInputAction: TextInputAction.next,
                                    obscureText: !passwordVisibility,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: HeronFitTheme
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(letterSpacing: 0.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.primaryDark,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.error,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.error,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: HeronFitTheme.bgSecondary,
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: HeronFitTheme.textMuted,
                                      ),
                                      suffixIcon: InkWell(
                                        onTap:
                                            () => setState(
                                              () =>
                                                  passwordVisibility =
                                                      !passwordVisibility,
                                            ),
                                        focusNode: FocusNode(
                                          skipTraversal: true,
                                        ),
                                        child: Icon(
                                          passwordVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: HeronFitTheme.textMuted,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    style: HeronFitTheme.textTheme.labelMedium
                                        ?.copyWith(letterSpacing: 0.0),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                  0,
                                  0,
                                  0,
                                  16,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: passwordConfirmTextController,
                                    autofocus: true,
                                    autofillHints: [AutofillHints.password],
                                    textInputAction: TextInputAction.send,
                                    obscureText: !passwordConfirmVisibility,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      labelStyle: HeronFitTheme
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(letterSpacing: 0.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.primaryDark,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.error,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: HeronFitTheme.error,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: HeronFitTheme.bgSecondary,
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: HeronFitTheme.textMuted,
                                      ),
                                      suffixIcon: InkWell(
                                        onTap:
                                            () => setState(
                                              () =>
                                                  passwordConfirmVisibility =
                                                      !passwordConfirmVisibility,
                                            ),
                                        focusNode: FocusNode(
                                          skipTraversal: true,
                                        ),
                                        child: Icon(
                                          passwordConfirmVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: HeronFitTheme.textMuted,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    style: HeronFitTheme.textTheme.labelMedium
                                        ?.copyWith(letterSpacing: 0.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                // Navigate to Privacy Policy screen
                              },
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'By continuing you accept our ',
                                      style: HeronFitTheme.textTheme.labelMedium
                                          ?.copyWith(letterSpacing: 0.0),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      mouseCursor: SystemMouseCursors.click,
                                      recognizer:
                                          TapGestureRecognizer()
                                            ..onTap = () {
                                              // Navigate to Privacy Policy screen
                                            },
                                    ),
                                    TextSpan(text: ' and', style: TextStyle()),
                                  ],
                                  style: HeronFitTheme.textTheme.labelMedium
                                      ?.copyWith(letterSpacing: 0.0),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              context.push(AppRoutes.profileTerms);
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Terms of Use',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    mouseCursor: SystemMouseCursors.click,
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            context.push(
                                              AppRoutes.profileTerms,
                                            );
                                          },
                                  ),
                                ],
                                style: HeronFitTheme.textTheme.labelMedium
                                    ?.copyWith(letterSpacing: 0.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.push(AppRoutes.registerVerify);
                        },
                        child: Text('Register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HeronFitTheme.primaryDark,
                          foregroundColor: HeronFitTheme.bgLight,
                          minimumSize: Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: HeronFitTheme.textTheme.titleSmall
                              ?.copyWith(
                                color: HeronFitTheme.bgLight,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            context.go(AppRoutes.login);
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(),
                                ),
                                TextSpan(
                                  text: 'Log In',
                                  style: HeronFitTheme.textTheme.labelMedium
                                      ?.copyWith(
                                        color: HeronFitTheme.primary,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                  mouseCursor: SystemMouseCursors.click,
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          context.go(AppRoutes.login);
                                        },
                                ),
                              ],
                              style: HeronFitTheme.textTheme.labelMedium
                                  ?.copyWith(
                                    color: HeronFitTheme.primary,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
