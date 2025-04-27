import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Returns the AuthResponse on success, otherwise throws error
Future<AuthResponse> verifyEmailWithToken(String email, String? token) async {
  final supabase = Supabase.instance.client;

  try {
    final AuthResponse res = await supabase.auth.verifyOTP(
      type: OtpType.signup,
      token: token ?? "",
      email: email,
    );

    // Check if verification was successful (user/session is usually present)
    if (res.session == null && res.user == null) {
      debugPrint('verifyOTP successful call but no session/user returned.');
      // This might happen in some edge cases, treat as failure for profile creation
      throw Exception('Verification failed: Invalid token or expired session.');
    }
    debugPrint(
      'verifyOTP successful: User ${res.user?.id}, Session ${res.session != null}',
    );
    return res;
  } on AuthException catch (e) {
    debugPrint("AuthException during verifyOTP: ${e.message}");
    throw Exception('Verification failed: ${e.message}');
  } catch (error) {
    debugPrint("Error during verifyOTP: $error");
    throw Exception('An unexpected error occurred during verification: $error');
  }
}
