import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// State definitions
abstract class PasswordRecoveryState {}

class PasswordRecoveryInitial extends PasswordRecoveryState {}

class PasswordRecoveryLoading
    extends PasswordRecoveryState {} // Generic loading state

// OTP Sent
class PasswordRecoveryOtpSent extends PasswordRecoveryState {
  final String email;
  PasswordRecoveryOtpSent(this.email);
}

// OTP Verification
class PasswordRecoveryOtpVerificationSuccess extends PasswordRecoveryState {}

// Password Update
class PasswordRecoveryFlowComplete extends PasswordRecoveryState {}

class PasswordRecoveryError extends PasswordRecoveryState {
  final String message;
  final RecoveryStage stage;
  PasswordRecoveryError(this.message, this.stage);
}

enum RecoveryStage { otpRequest, otpVerification, passwordUpdate }

class PasswordRecoveryController extends StateNotifier<PasswordRecoveryState> {
  PasswordRecoveryController() : super(PasswordRecoveryInitial());

  String? _currentEmail; // Store email for OTP verification step

  // Step 1: Send OTP to user's email
  Future<void> sendRecoveryOtp(String email) async {
    state = PasswordRecoveryLoading();
    _currentEmail = email; // Store for verification
    try {
      // For password recovery, shouldCreateUser should ideally be false.
      // Supabase sends a generic OTP. The 'type' is specified during verifyOtp.
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false, // Important: don't create new user
        // Supabase plans to support `channel` selection e.g. 'sms' or 'email'
        // but for now, it defaults to email if phone is not provided.
      );
      state = PasswordRecoveryOtpSent(email); // Pass email here
    } on AuthException catch (e) {
      state = PasswordRecoveryError(e.message, RecoveryStage.otpRequest);
    } catch (e) {
      state = PasswordRecoveryError(
        'An unexpected error occurred. Please try again.',
        RecoveryStage.otpRequest,
      );
    }
  }

  // Step 2: Verify OTP
  Future<void> verifyRecoveryOtp(String otp) async {
    if (_currentEmail == null) {
      state = PasswordRecoveryError(
        'Email not found. Please restart the recovery process.',
        RecoveryStage.otpVerification,
      );
      return;
    }
    state = PasswordRecoveryLoading();
    try {
      final AuthResponse response = await Supabase.instance.client.auth
          .verifyOTP(token: otp, type: OtpType.recovery, email: _currentEmail);
      if (response.session != null) {
        // OTP verified, user is effectively "authenticated" for password update
        state = PasswordRecoveryOtpVerificationSuccess();
      } else {
        // If session is null, but no AuthException, it might mean OTP was incorrect
        state = PasswordRecoveryError(
          'Invalid OTP. Please try again.',
          RecoveryStage.otpVerification,
        );
      }
    } on AuthException catch (e) {
      state = PasswordRecoveryError(e.message, RecoveryStage.otpVerification);
    } catch (e) {
      state = PasswordRecoveryError(
        'An unexpected error occurred during OTP verification.',
        RecoveryStage.otpVerification,
      );
    }
  }

  // Step 3: Update Password
  Future<void> updateUserPassword(String newPassword) async {
    state = PasswordRecoveryLoading();
    try {
      // User should be authenticated from verifyOtp step
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      state = PasswordRecoveryFlowComplete();
    } on AuthException catch (e) {
      state = PasswordRecoveryError(e.message, RecoveryStage.passwordUpdate);
    } catch (e) {
      state = PasswordRecoveryError(
        'An unexpected error occurred while updating your password.',
        RecoveryStage.passwordUpdate,
      );
    }
  }
}

final passwordRecoveryControllerProvider =
    StateNotifierProvider<PasswordRecoveryController, PasswordRecoveryState>(
      (ref) => PasswordRecoveryController(),
    );
