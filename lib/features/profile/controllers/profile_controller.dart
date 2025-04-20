import 'dart:io'; // Import dart:io for File
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/profile/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

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
  ProfileController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;
  final _supabase = Supabase.instance.client;

  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    state = const AsyncValue.loading(); // Set loading state

    final user = _supabase.auth.currentUser;

    if (user == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }

    try {
      // Update the 'users' table
      await _supabase
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

  // Method to upload avatar and update user profile
  Future<void> uploadAndUpdateAvatar(XFile imageFile) async {
    state = const AsyncValue.loading();
    final user = _supabase.auth.currentUser;

    if (user == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }

    String? oldAvatarPath; // Variable to store the path of the old avatar

    try {
      // --- Get old avatar path BEFORE uploading new one ---
      final currentUserData = await ref.read(userProfileProvider.future);
      if (currentUserData?.avatar != null &&
          currentUserData!.avatar!.isNotEmpty) {
        try {
          // Extract the path from the public URL
          final uri = Uri.parse(currentUserData.avatar!);
          // Assuming URL format: .../storage/v1/object/public/avatars/avatar_path.jpg
          // Find the bucket name in the path segments
          final bucketName = 'avatars'; // Your bucket name
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf(bucketName);
          if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
            oldAvatarPath = pathSegments.sublist(bucketIndex + 1).join('/');
          }
        } catch (e) {
          print("Error parsing old avatar URL: $e");
          // Decide if you want to proceed without deleting or stop
        }
      }
      // --- End Get old avatar path ---

      final fileExt = p.extension(imageFile.path);
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final newAvatarPath = 'avatars/$fileName'; // Path for the new avatar

      // 1. Upload NEW image to Supabase Storage
      final uploadResponse = await _supabase.storage
          .from('avatars')
          .upload(
            newAvatarPath,
            File(imageFile.path),
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ), // Consider upsert: true if you want to overwrite by path, but unique names are safer
          );

      // Check for upload errors explicitly
      if (uploadResponse.isEmpty) {
        throw Exception(
          'Failed to upload image: Empty response from storage upload.',
        );
      }

      // 2. Get the public URL of the NEW uploaded image
      final newImageUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(newAvatarPath);

      // 3. Update the user's avatar URL in the database
      await _supabase
          .from('users')
          .update({'avatar': newImageUrl})
          .eq('id', user.id);

      // --- Delete OLD avatar AFTER successful upload and DB update ---
      if (oldAvatarPath != null && oldAvatarPath.isNotEmpty) {
        try {
          print("Attempting to delete old avatar: $oldAvatarPath");
          await _supabase.storage.from('avatars').remove([oldAvatarPath]);
          print("Successfully deleted old avatar.");
        } catch (e) {
          print("Error deleting old avatar '$oldAvatarPath': $e");
          // Log this error, but don't necessarily fail the whole operation
          // as the main goal (uploading new avatar) succeeded.
        }
      }
      // --- End Delete old avatar ---

      // 4. Invalidate providers to reflect changes
      ref.invalidate(userProfileProvider);

      state = const AsyncValue.data(null); // Success
    } on StorageException catch (e, st) {
      print('Storage Error uploading/deleting avatar: ${e.message}');
      state = AsyncValue.error('Storage Error: ${e.message}', st);
    } catch (e, st) {
      print('Error in uploadAndUpdateAvatar: $e');
      state = AsyncValue.error('Failed to update avatar: $e', st);
    }
  }

  // Optional: Add a method to remove avatar without uploading a new one
  Future<void> removeAvatar() async {
    state = const AsyncValue.loading();
    final user = _supabase.auth.currentUser;

    if (user == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }

    String? avatarPathToRemove;

    try {
      // 1. Get current avatar URL and path
      final currentUserData = await ref.read(userProfileProvider.future);
      if (currentUserData?.avatar != null &&
          currentUserData!.avatar!.isNotEmpty) {
        try {
          final uri = Uri.parse(currentUserData.avatar!);
          final bucketName = 'avatars';
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf(bucketName);
          if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
            avatarPathToRemove = pathSegments
                .sublist(bucketIndex + 1)
                .join('/');
          }
        } catch (e) {
          print("Error parsing avatar URL for removal: $e");
          // If URL is invalid, maybe the DB entry is wrong? Still try to clear DB field.
        }
      } else {
        // No avatar set, nothing to remove from storage or DB
        state = const AsyncValue.data(null);
        return;
      }

      // 2. Update database first (set avatar to null or empty string)
      await _supabase
          .from('users')
          .update({'avatar': null}) // Set to null
          .eq('id', user.id);

      // 3. Delete from storage AFTER successful DB update
      if (avatarPathToRemove != null && avatarPathToRemove.isNotEmpty) {
        try {
          print(
            "Attempting to remove avatar from storage: $avatarPathToRemove",
          );
          await _supabase.storage.from('avatars').remove([avatarPathToRemove]);
          print("Successfully removed avatar from storage.");
        } catch (e) {
          print("Error removing avatar '$avatarPathToRemove' from storage: $e");
          // Log error, but DB update was the primary goal here.
        }
      }

      // 4. Invalidate provider
      ref.invalidate(userProfileProvider);
      state = const AsyncValue.data(null); // Success
    } catch (e, st) {
      print('Error removing avatar: $e');
      state = AsyncValue.error('Failed to remove avatar: $e', st);
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
