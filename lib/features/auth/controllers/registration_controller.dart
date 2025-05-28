import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart'; // Added for debugPrint
import '../models/registration_model.dart';

class RegistrationController extends StateNotifier<RegistrationModel> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Ref _ref; // Add Ref if needed for reading other providers

  RegistrationController(this._ref) : super(const RegistrationModel());

  void updateFirstName(String value) =>
      state = state.copyWith(firstName: value);
  void updateLastName(String value) => state = state.copyWith(lastName: value);
  void updateEmail(String value) => state = state.copyWith(email: value);
  void updatePassword(String value) => state = state.copyWith(password: value);
  void updateGender(String value) => state = state.copyWith(gender: value);
  void updateBirthday(String value) => state = state.copyWith(birthday: value);
  void updateWeight(String value) => state = state.copyWith(weight: value);
  void updateHeight(String value) => state = state.copyWith(height: value);
  void updateGoal(String value) => state = state.copyWith(goal: value);
  void updateUserRole(String value) => state = state.copyWith(userRole: value);
  void updateRoleStatus(String value) => state = state.copyWith(roleStatus: value);
  void updateVerificationDocumentUrl(String? value) =>
      state = state.copyWith(verificationDocumentUrl: value, setVerificationDocumentUrlToNull: value == null);

  void reset() => state = const RegistrationModel();

  // Step 1: Initiate Sign Up (sends verification email)
  // This method is now primarily handled by AuthController, which will read RegistrationModel state.
  // Keeping it here for reference or if parts of it are still used locally before calling AuthController.
  Future<void> initiateSignUp() async {
    debugPrint('Attempting to initiate sign up for: ${state.email}');
    debugPrint('Role: ${state.userRole}, Status: ${state.roleStatus}, Doc URL: ${state.verificationDocumentUrl}'); // Log role data
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: state.email,
        password: state.password,
        data: {
          // Temporarily sending a minimal payload for debugging
          'debug_signup_attempt': true,
          'user_role': state.userRole, // Keep user_role as it's fundamental
          'role_status': state.roleStatus, // Keep role_status
          'first_name': state.firstName, // Keep essential names
          'last_name': state.lastName
          // Commenting out other fields to isolate the issue:
          // 'full_name': '${state.firstName} ${state.lastName}', // public.users doesn't have this
          // 'verification_document_url': state.verificationDocumentUrl, 
          // 'gender': state.gender,
          // 'birth_date': state.birthDate?.toIso8601String(),
          // 'fitness_goal': state.fitnessGoal,
          // 'activity_level': state.activityLevel,
        },
      );
      debugPrint('Supabase signUp call completed.');
      // Check if user requires confirmation - success even if user exists but is unconfirmed
      if (res.user == null && res.session != null) {
        debugPrint(
          'Sign up initiated, session exists but user is null (likely existing unconfirmed user).',
        );
        // Allow proceeding to verification
      } else if (res.user != null) {
        debugPrint(
          'Sign up initiated successfully for new user: ${res.user!.id}',
        );
        // Allow proceeding to verification
      } else {
        // This case might indicate an unexpected issue or configuration problem
        debugPrint('Supabase signUp response has null user and null session.');
        throw Exception('Sign up initiation failed. Please try again.');
      }
    } on AuthException catch (e) {
      debugPrint(
        'Supabase AuthException during signUp initiation: ${e.message}',
      );
      if (e.message.toLowerCase().contains('user already registered')) {
        // Consider if you want to let them proceed to verify anyway, or show error
        // Let's throw a specific error for now.
        throw Exception(
          'This email is already registered. Please log in or try verifying.',
        );
      }
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      debugPrint('General error during signUp initiation: ${e.toString()}');
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Step 2: Insert User Profile (called AFTER successful OTP verification)
  // This method inserts additional details not typically part of raw_user_meta_data during signup.
  // user_role, role_status, verification_document_url are expected to be in public.users via a trigger from auth.users.
  Future<void> insertUserProfile(String userId) async {
    debugPrint('Attempting to insert profile for user ID: $userId');
    try {
      // Check if user already exists to prevent re-inserting/overwriting if this is called multiple times
      // This is a simple check; more robust handling might be needed depending on flow
      final existingUser = await _supabase.from('users').select('id').eq('id', userId).maybeSingle();
      if (existingUser != null) {
        debugPrint('User profile for $userId already exists. Skipping insert.');
        // Optionally, update existing fields if necessary, but for now, we skip.
        return;
      }

      await _supabase.from('users').insert({
        'id': userId,
        'first_name': state.firstName,
        'last_name': state.lastName,
        'email_address': state.email, // Use the correct column name
        'gender': state.gender,
        'birthday': state.birthday.isEmpty ? null : state.birthday,
        'weight': state.weight,
        'height': int.tryParse(state.height),
        'goal': state.goal,
        // 'user_role': state.userRole, // Should be set by trigger from auth.users
        // 'role_status': state.roleStatus, // Should be set by trigger from auth.users
        // 'verification_document_url': state.verificationDocumentUrl, // Should be set by trigger
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('User profile inserted successfully for user: $userId');
    } catch (e) {
      debugPrint('Error inserting user profile for $userId: ${e.toString()}');
      // Decide how to handle profile insertion failure - user is verified but profile failed.
      // Maybe log it, notify admin, or inform user?
      // For now, rethrow to indicate the step failed.
      throw Exception('Failed to save user profile details: ${e.toString()}');
    }
  }
}

final registrationProvider =
    StateNotifierProvider<RegistrationController, RegistrationModel>((ref) {
  return RegistrationController(ref);
});
