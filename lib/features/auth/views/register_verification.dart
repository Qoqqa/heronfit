import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; // Ensure this package is correctly added to pubspec.yaml
import '../../../core/theme.dart'; // Updated import path
import 'register_screen.dart'; // Import the RegisterWidget

class RegisterVerificationWidget extends StatefulWidget {
  const RegisterVerificationWidget({
    super.key,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;

  static String routeName = 'RegisterVerification';
  static String routePath = '/registerVerification';

  @override
  State<RegisterVerificationWidget> createState() =>
      _RegisterVerificationWidgetState();
}

class _RegisterVerificationWidgetState
    extends State<RegisterVerificationWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController pinCodeController = TextEditingController();
  final FocusNode pinCodeFocusNode = FocusNode();

  @override
  void dispose() {
    pinCodeController.dispose();
    pinCodeFocusNode.dispose();
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
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: AssetImage(
                                'assets/images/RegisterVerification.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(-1, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                          child: Text(
                            'Verify your email',
                            textAlign: TextAlign.start,
                            style: HeronFitTheme.textTheme.headlineSmall
                                ?.copyWith(
                                  color: HeronFitTheme.primary,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(-1, 0),
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
                                text: widget.email,
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const RegisterWidget(),
                                          ),
                                        );
                                      },
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
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        textStyle: HeronFitTheme.textTheme.labelMedium
                            ?.copyWith(
                              color: HeronFitTheme.textPrimary,
                              letterSpacing: 0.0,
                            ),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        enableActiveFill: true,
                        autoFocus: true,
                        focusNode: pinCodeFocusNode,
                        enablePinAutofill: true,
                        errorTextSpace: 16,
                        showCursor: false,
                        cursorColor: HeronFitTheme.primary,
                        obscureText: false,
                        hintCharacter: '*',
                        keyboardType: TextInputType.number,
                        pinTheme: PinTheme(
                          fieldHeight: 48,
                          fieldWidth: 48,
                          borderWidth: 2,
                          borderRadius: BorderRadius.circular(8),
                          shape: PinCodeFieldShape.box,
                          activeColor: HeronFitTheme.primary,
                          inactiveColor: HeronFitTheme.bgSecondary,
                          selectedColor: HeronFitTheme.bgSecondary,
                          activeFillColor: HeronFitTheme.bgSecondary,
                          inactiveFillColor: HeronFitTheme.bgSecondary,
                          selectedFillColor: HeronFitTheme.bgSecondary,
                        ),
                        controller: pinCodeController,
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        // Resend Code
                      },
                      child: Text(
                        'Resend Code',
                        style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                          color: HeronFitTheme.primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
                      child: ElevatedButton(
                        onPressed: () {
                          // Confirm
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HeronFitTheme.primaryDark,
                          foregroundColor: HeronFitTheme.bgLight,
                          minimumSize: Size(double.infinity, 48),
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
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterWidget(),
                          ),
                        );
                      },
                      child: Text(
                        'Change Email',
                        style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                          color: HeronFitTheme.primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
