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
          'first_name': state.firstName,
          'last_name': state.lastName,
          'gender': state.gender,
          'birthday': state.birthday,
          'weight': state.weight,
          'height': state.height,
          'goal': state.goal,
          'user_role': state.userRole,
          'role_status': state.roleStatus,
          'verification_document_url': state.verificationDocumentUrl,
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
    try {
      // Log all the state values for debugging
      debugPrint('Saving user profile with data:');
      debugPrint('First Name: ${state.firstName}');
      debugPrint('Last Name: ${state.lastName}');
      debugPrint('Email: ${state.email}');
      debugPrint('Gender: ${state.gender}');
      debugPrint('Birthday: ${state.birthday}');
      debugPrint('Weight: ${state.weight}');
      debugPrint('Height: ${state.height}');
      debugPrint('Goal: ${state.goal}');
      debugPrint('User Role: ${state.userRole}');
      debugPrint('Role Status: ${state.roleStatus}');
      debugPrint('Verification Doc URL: ${state.verificationDocumentUrl}');

      // First, check if user exists and get current data
      final existingUser = await _supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      final userData = <String, dynamic>{
        'id': userId,
        'first_name': state.firstName,
        'last_name': state.lastName,
        'email_address': state.email,
        'gender': state.gender,
        'birthday': state.birthday.isEmpty ? null : state.birthday,
        'weight': state.weight,
        'height': int.tryParse(state.height),
        'goal': state.goal,
        'user_role': state.userRole,
        'role_status': state.roleStatus,
        'verification_document_url': state.verificationDocumentUrl,
      };

      if (existingUser != null) {
        debugPrint('Updating existing profile for user: $userId');
        // Remove null values to avoid overwriting existing data with null
        userData.removeWhere((key, value) => value == null);
        
        // Update existing user
        try {
          final response = await _supabase
              .from('users')
              .update(userData)
              .eq('id', userId);
          debugPrint('Update response: $response');
        } catch (e) {
          debugPrint('Error updating user: $e');
          // If update fails, try with only the essential fields
          final essentialData = <String, dynamic>{
            'first_name': state.firstName,
            'last_name': state.lastName,
            'email_address': state.email,
            'gender': state.gender,
          };
          final fallbackResponse = await _supabase
              .from('users')
              .update(essentialData)
              .eq('id', userId);
          debugPrint('Fallback update response: $fallbackResponse');
        }
      } else {
        debugPrint('Creating new profile for user: $userId');
        // For new users, include created_at
        final newUserData = Map<String, dynamic>.from(userData);
        newUserData['created_at'] = DateTime.now().toIso8601String();
        
        try {
          final response = await _supabase
              .from('users')
              .insert(newUserData);
          debugPrint('Insert response: $response');
        } catch (e) {
          debugPrint('Error creating user: $e');
          // If insert fails with full data, try with minimal required fields
          final minimalUserData = {
            'id': userId,
            'first_name': state.firstName,
            'last_name': state.lastName,
            'email_address': state.email,
            'created_at': DateTime.now().toIso8601String(),
          };
          final fallbackResponse = await _supabase
              .from('users')
              .insert(minimalUserData);
          debugPrint('Fallback insert response: $fallbackResponse');
        }
      }
      
      // Verify the data was saved correctly
      try {
        final savedUser = await _supabase
            .from('users')
            .select()
            .eq('id', userId)
            .single();
        
        debugPrint('User profile saved successfully. Current data:');
        debugPrint(savedUser.toString());
      } catch (e) {
        debugPrint('Error verifying saved user data: $e');
      }
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
