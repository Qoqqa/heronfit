import 'package:supabase_flutter/supabase_flutter.dart';

class SignupService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Step 1: Register the user with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Step 2: Insert additional user data into the 'user' table
        final userId = response.user!.id; // Get the user's unique ID
        final insertResponse = await _supabase.from('user').insert({
          'id': userId, // Use the user's unique ID as the primary key
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
        });

        if (insertResponse.error != null) {
          return 'Error saving user data: ${insertResponse.error!.message}';
        }

        return null; // Success
      } else {
        return 'Registration failed';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}