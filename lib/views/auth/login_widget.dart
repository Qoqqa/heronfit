import '../../controllers/auth/login_controller.dart'; // Adjust path if needed
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/login_model.dart';
import '../../core/theme.dart'; // Import your theme

export '../../models/login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'Login';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  LoginModel createModel(
    BuildContext context,
    LoginModel Function() modelCreator,
  ) {
    return modelCreator();
  }

  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
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
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 48.0, 24.0, 48.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:
                          [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'Great To See You Again!',
                                      textAlign: TextAlign.center,
                                      style: HeronFitTheme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: HeronFitTheme.primary,
                                          ),
                                    ),
                                    Text(
                                      'Let\'s pick up where you left off.',
                                      textAlign: TextAlign.center,
                                      style: HeronFitTheme.textTheme.titleLarge
                                          ?.copyWith(
                                            color: HeronFitTheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                Form(
                                  key: _model.formKey,
                                  autovalidateMode: AutovalidateMode.disabled,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0,
                                          0.0,
                                          0.0,
                                          16.0,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          child: TextFormField(
                                            controller:
                                                _model
                                                    .emailAddressTextController,
                                            focusNode:
                                                _model.emailAddressFocusNode,
                                            autofocus: true,
                                            autofillHints: [
                                              AutofillHints.email,
                                            ],
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              labelText: 'Email Address',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            style:
                                                HeronFitTheme
                                                    .textTheme
                                                    .labelMedium,
                                            // validator: _model
                                            //     .emailAddressTextControllerValidator
                                            //     .asValidator(context),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0,
                                          0.0,
                                          0.0,
                                          16.0,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          child: TextFormField(
                                            controller:
                                                _model.passwordTextController,
                                            focusNode: _model.passwordFocusNode,
                                            autofocus: true,
                                            autofillHints: [
                                              AutofillHints.password,
                                            ],
                                            decoration: InputDecoration(
                                              labelText: 'Password',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            style:
                                                HeronFitTheme
                                                    .textTheme
                                                    .labelMedium,
                                            // validator: _model
                                            //     .passwordTextControllerValidator
                                            //     .asValidator(context),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          // ForgotPassword

                                          // context.pushNamed(
                                          //     ForgotPasswordWidget.routeName);
                                        },
                                        child: Text(
                                          'Forgot your password?',
                                          style: HeronFitTheme
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                              .map(
                                (widget) => Padding(
                                  padding: const EdgeInsets.only(bottom: 48.0),
                                  child: widget,
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, 1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
                            0.0,
                            0.0,
                            8.0,
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              final email =
                                  _model.emailAddressTextController!.text.trim();
                              final password =
                                  _model.passwordTextController!.text.trim();

                              if (email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please fill in all fields'),
                                  ),
                                );
                                return;
                              }

                              try {
                                final response = await Supabase
                                    .instance
                                    .client
                                    .auth
                                    .signInWithPassword(
                                      email: email,
                                      password: password,
                                    );

                                if (response.user != null) {
                                  // Navigate to the home screen or another page
                                  Navigator.pushNamed(context, '/home');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Login failed')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HeronFitTheme.primaryDark,
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login, size: 24.0),
                                SizedBox(width: 8.0),
                                Text(
                                  'Log In',
                                  style: HeronFitTheme.textTheme.labelMedium
                                      ?.copyWith(color: HeronFitTheme.bgLight),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              // Register

                              // context.pushNamed(RegisterWidget.routeName);
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Don\'t have an account?',
                                    style: HeronFitTheme.textTheme.labelMedium,
                                  ),
                                  TextSpan(
                                    text: ' Register',
                                    style: HeronFitTheme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: HeronFitTheme.primaryDark,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
