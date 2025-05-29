import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    required String birthday,
    required String weight,
    required String height,
    required String goal,
  }) async {
    try {
      // Step 1: Register the user with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'gender': gender,
          'birthday': birthday,
          'weight': weight,
          'height': height,
          'goal': goal,
        },
      );

      if (response.user != null) {
        // Step 2: Insert additional user data into the 'users' table
        final userId = response.user!.id;
        final userData = {
          'id': userId,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'gender': gender,
          'birthday': birthday.isEmpty ? null : birthday,
          'weight': weight,
          'height': height.isNotEmpty ? int.tryParse(height) : null,
          'goal': goal,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        final insertResponse = await _supabase
            .from('users')
            .insert(userData);

        if (insertResponse.error != null) {
          // Log the error for debugging
          debugPrint('Error saving user data: ${insertResponse.error!.message}');
          return 'Error saving user data. Please try again.';
        }

        return null; // Success
      } else {
        debugPrint('Registration failed: No user returned from auth.signUp');
        return 'Registration failed. Please try again.';
      }
    } on AuthException catch (e) {
      debugPrint('AuthException during registration: ${e.message}');
      return 'Registration error: ${e.message}';
    } catch (e) {
      debugPrint('Error during registration: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }
}