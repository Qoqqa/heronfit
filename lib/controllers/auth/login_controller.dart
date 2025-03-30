import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_client.dart';

class LoginController {
  // Login function using Supabase authentication
  static Future<AuthResponse?> login(String email, String password) async {
    try {
      final response = await SupabaseClientManager.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response; // Returns AuthResponse containing user session
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Check if the user is already logged in
  static User? getCurrentUser() {
    return SupabaseClientManager.client.auth.currentUser;
  }                      

  // Logout function
  static Future<void> logout() async {
    await SupabaseClientManager.client.auth.signOut();
  }
}
