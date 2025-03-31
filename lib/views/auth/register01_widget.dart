import 'package:flutter/material.dart';
import '../../core/theme.dart'; // Import your theme
import '../../models/register01_model.dart'; // Import the RegisterModel
import 'registerverification_widget.dart'; // Import RegisterVerificationWidget

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  static String routeName = 'Register';
  static String routePath = '/register';

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  late RegisterModel _model;

  @override
  void initState() {
    super.initState();
    _model = RegisterModel();
    _model.initState();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_model.formKey.currentState?.validate() ?? false) {
      final result = await _model.registerUser();

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful! Please verify your email.')),
        );

        // Navigate to the RegisterVerificationWidget
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterVerificationWidget(
              email: _model.emailAddressTextController?.text.trim() ?? '',
              password: _model.passwordTextController?.text.trim() ?? '',
              confirmPassword: _model.passwordConfirmTextController?.text.trim() ?? '',
              firstName: _model.firstNameTextController?.text.trim() ?? '',
              lastName: _model.lastNameTextController?.text.trim() ?? '',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'Welcome to HeronFit',
                      //style: TextStyle(//
                        style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                          color: HeronFitTheme.primary,
                          letterSpacing: 0.0,
                        //fontSize: 24,
                        //fontWeight: FontWeight.w500,
                        //color: Colors.blue,//
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ready to Begin?',
                      style: HeronFitTheme.textTheme.headlineLarge?.copyWith(
                          color: HeronFitTheme.primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                      //style: TextStyle(//
                        //fontSize: 32,
                        //fontWeight: FontWeight.bold,
                        //color: Colors.blue,//
                      ),
                    ),
                  ],
                ),
                Form(
                  key: _model.formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _model.firstNameTextController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: _model.firstNameTextControllerValidator,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _model.lastNameTextController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: _model.lastNameTextControllerValidator,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _model.emailAddressTextController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _model.emailAddressTextControllerValidator,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _model.passwordTextController,
                        obscureText: !_model.passwordVisibility,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _model.passwordVisibility
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _model.passwordVisibility =
                                    !_model.passwordVisibility;
                              });
                            },
                          ),
                        ),
                        validator: _model.passwordTextControllerValidator,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _model.passwordConfirmTextController,
                        obscureText: !_model.passwordConfirmVisibility,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _model.passwordConfirmVisibility
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _model.passwordConfirmVisibility =
                                    !_model.passwordConfirmVisibility;
                              });
                            },
                          ),
                        ),
                        validator: _model.passwordConfirmTextControllerValidator,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _register,        
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HeronFitTheme.primaryDark, // Use the same background color
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.app_registration, size: 24.0, color: HeronFitTheme.bgLight), // Icon for "Register"
                          SizedBox(width: 8.0),
                           Text(
                            'Register',
                          style: HeronFitTheme.textTheme.labelMedium
                              ?.copyWith(color: HeronFitTheme.bgLight), // Text style
                           ),
                        ],
                        ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      //child: Text('Already have an account? Log In'),//
                        child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account?',
                                    style: HeronFitTheme.textTheme.labelMedium,
                                  ),
                                  TextSpan(
                                    text: ' Log In',
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