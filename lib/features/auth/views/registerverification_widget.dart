import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart'; // Import the new package
import '../controllers/verify_email_controller.dart'; // Updated import path

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

  @override
  State<RegisterVerificationWidget> createState() =>
      _RegisterVerificationWidgetState();
}

class _RegisterVerificationWidgetState
    extends State<RegisterVerificationWidget> {
  String _pinCode = '';
  bool _isVerified = false;

  Future<void> _verifyEmail(String email, String pinCode) async {
    final isVerified = await verifyEmailWithToken(email, pinCode);

    if (isVerified) {
      setState(() {
        _isVerified = true;
      });

      // Navigate to the login screen after successful verification
      Navigator.pushNamed(context, '/login');
    } else {
      setState(() {
        _isVerified = false;
      });

      // Show an error dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Verification Failed'),
            content: Text('The PIN code is incorrect. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
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
                    Container(
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Verify your email',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Please enter the 6-digit code sent to ',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: widget.email,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: ' to verify your account.',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    OtpTextField(
                      numberOfFields: 6,
                      borderColor: Colors.blue,
                      showFieldAsBox: true,
                      onCodeChanged: (String code) {
                        // Handle code change
                      },
                      onSubmit: (String verificationCode) {
                        setState(() {
                          _pinCode = verificationCode;
                        });
                      }, // End onSubmit
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _verifyEmail(widget.email, _pinCode);
                      },
                      child: Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Resend code logic here
                      },
                      child: Text(
                        'Resend Code',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'Change Email',
                        style: TextStyle(color: Colors.blue),
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
