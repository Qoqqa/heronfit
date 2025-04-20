import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/profile/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

// Provider to fetch the current user's profile data
// Using FutureProvider for a one-time fetch, could be StreamProvider for real-time updates
final userProfileProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    // Not logged in, return null or throw an error
    return null;
  }

  try {
    // Assuming your profile table is named 'users' and linked by user ID
    final response =
        await supabase
            .from('users') // Changed from 'profiles'
            .select()
            .eq('id', user.id)
            .single(); // Use .single() if you expect exactly one row

    // Create UserModel from the response map
    return UserModel.fromMap(response, user.id);
  } catch (e) {
    // Handle errors (e.g., profile not found, network issue)
    print('Error fetching user profile: $e');
    // Rethrow or return null based on how you want to handle errors in the UI
    rethrow;
  }
});

// Controller for handling profile update logic
class ProfileController extends StateNotifier<AsyncValue<void>> {
  ProfileController(this.ref)
    : super(const AsyncValue.data(null)); // Initial state

  final Ref ref;

  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    state = const AsyncValue.loading(); // Set loading state

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }

    try {
      // Update the 'users' table
      await supabase
          .from('users')
          .update(updatedData)
          .eq('id', user.id); // Changed from 'profiles'

      // Invalidate the userProfileProvider to refetch the updated data
      ref.invalidate(userProfileProvider);

      state = const AsyncValue.data(null); // Set success state
    } catch (e, st) {
      print('Error updating profile: $e');
      state = AsyncValue.error(e, st); // Set error state
      // Optionally rethrow if the UI needs to handle it further
      // rethrow;
    }
  }
}

// Provider for the ProfileController
final profileControllerProvider =
    StateNotifierProvider.autoDispose<ProfileController, AsyncValue<void>>((
      ref,
    ) {
      return ProfileController(ref);
    });
