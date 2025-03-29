import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> verifyEmailWithToken(
  String email,
  String? token,
) async {
  // Instantiate Supabase client
  final supabase = Supabase.instance.client;

  try {
    // Call the Supabase verifyOTP function
    // If successful, a response with the user and session is returned
    final AuthResponse res = await supabase.auth.verifyOTP(
      type: OtpType.signup,
      token: token ?? "",
      email: email,
    );

    // Return true if session is not null (i.e., user has signed in)
    return res.session != null;
  } on AuthException catch (e) {
    // Catch any authentication errors and print them to the console
    debugPrint("AuthException: ${e.message}");
    return false;
  } catch (error) {
    // Catch any other errors
    debugPrint("Error: $error");
    return false;
  }
}