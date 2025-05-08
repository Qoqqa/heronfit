import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// State definitions
abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  ForgotPasswordError(this.message);
}

class ForgotPasswordController extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordController() : super(ForgotPasswordInitial());

  Future<void> sendResetLink(String email) async {
    state = ForgotPasswordLoading();
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        // You can specify a redirectTo URL if you have a specific page in your app
        // for users to land on after resetting password from the email link.
        // This requires deep linking setup.
        // redirectTo: 'io.supabase.heronfit://password-reset-confirm/',
      );
      state = ForgotPasswordSuccess();
    } on AuthException catch (e) {
      state = ForgotPasswordError(e.message);
    } catch (e) {
      state = ForgotPasswordError(
        'An unexpected error occurred. Please try again.',
      );
    }
  }
}

final forgotPasswordControllerProvider =
    StateNotifierProvider<ForgotPasswordController, ForgotPasswordState>(
      (ref) => ForgotPasswordController(),
    );
