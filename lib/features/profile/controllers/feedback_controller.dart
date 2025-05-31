import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heronfit/core/services/supabase_service.dart'; // Assuming you have a Supabase service wrapper

// Define the state for feedback sending
enum FeedbackStatus { initial, loading, success, error }

class FeedbackState {
  final FeedbackStatus status;
  final String? errorMessage;

  FeedbackState({this.status = FeedbackStatus.initial, this.errorMessage});

  FeedbackState copyWith({FeedbackStatus? status, String? errorMessage}) {
    return FeedbackState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Define the controller
class FeedbackController extends StateNotifier<FeedbackState> {
  final SupabaseClient _supabase;

  FeedbackController(this._supabase) : super(FeedbackState());

  Future<void> sendFeedback(String message) async {
    if (message.trim().isEmpty) {
      state = FeedbackState(
        status: FeedbackStatus.error,
        errorMessage: 'Feedback message cannot be empty.',
      );
      return;
    }

    state = FeedbackState(status: FeedbackStatus.loading);

    try {
      final user = _supabase.auth.currentUser;

      await _supabase.from('feedback').insert({
        'user_id': user?.id, // Associate with logged-in user if available
        'message': message.trim(),
        // 'created_at' will be set by the database default value
      });

      state = FeedbackState(status: FeedbackStatus.success);
    } catch (e) {
      state = FeedbackState(
        status: FeedbackStatus.error,
        errorMessage: 'Failed to send feedback: ${e.toString()}',
      );
    }
  }

  void resetState() {
    state = FeedbackState();
  }
}

// Provide the controller
final feedbackControllerProvider =
    StateNotifierProvider<FeedbackController, FeedbackState>((ref) {
      // Use your existing Supabase client provider or access directly
      final supabase = Supabase.instance.client;
      return FeedbackController(supabase);
    });
