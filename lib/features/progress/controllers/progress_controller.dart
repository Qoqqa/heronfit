import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/progress/models/progress_record.dart'; // Use the model definition
import 'package:image_picker/image_picker.dart'; // Import image_picker for XFile
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_controller.g.dart';

// Provider to fetch progress records (weight history, photos)
final progressRecordsProvider =
    StateNotifierProvider<ProgressNotifier, AsyncValue<List<ProgressRecord>>>((
      ref,
    ) {
      return ProgressNotifier();
    });

class ProgressNotifier extends StateNotifier<AsyncValue<List<ProgressRecord>>> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  ProgressNotifier() : super(const AsyncValue.loading()) {
    fetchProgressRecords();
  }

  Future<void> fetchProgressRecords() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabaseClient
          .from('progress_records')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      final data = response as List<dynamic>;
      state = AsyncValue.data(
        data
            .map((e) => ProgressRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addWeightEntry(double weight, String? picUrl) async {
    // Implementation for adding weight entry
  }
}

@riverpod
Future<UserGoal?> userGoals(UserGoalsRef ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    // Not logged in, return null or throw an error
    return null;
  }

  try {
    final response =
        await supabase
            .from(
              'goals',
            ) // Correct the table name from 'user_goals' to 'goals'
            .select()
            .eq('user_id', userId)
            .maybeSingle(); // Use maybeSingle() in case no goal is set yet

    if (response == null) {
      return null; // No goal found for the user
    }

    return UserGoal.fromJson(response);
  } catch (e) {
    return null; // Return null on error for now
  }
}

// Controller for handling progress-related actions (saving data)
class ProgressController extends StateNotifier<AsyncValue<void>> {
  ProgressController() : super(const AsyncValue.data(null));

  final _supabaseClient = Supabase.instance.client;
  final _uuid = const Uuid();

  // Method to save a new weight entry (with optional photo)
  Future<void> saveWeightEntry({
    required double weight,
    required DateTime date,
    XFile? photoFile, // Use XFile from image_picker
  }) async {
    state = const AsyncValue.loading();
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }

    String? photoUrl;
    String? photoPath;

    try {
      // 1. Upload photo if provided
      if (photoFile != null) {
        final fileExt = photoFile.path.split('.').last;
        photoPath = '${user.id}/${_uuid.v4()}.$fileExt'; // Unique path

        await _supabaseClient.storage
            .from('progress-photos') // Corrected bucket name
            .upload(
              photoPath,
              File(photoFile.path),
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
        // Get public URL (adjust bucket name if needed)
        photoUrl = _supabaseClient.storage
            .from('progress-photos') // Corrected bucket name
            .getPublicUrl(photoPath);
      }

      // 2. Insert progress record into the database
      await _supabaseClient.from('progress_records').insert({
        'user_id': user.id,
        'date': date.toIso8601String(),
        'weight': weight,
        'photo_url': photoUrl, // Store the public URL
        'photo_path':
            photoPath, // Store the storage path (optional, for deletion)
      });

      state = const AsyncValue.data(null); // Success
    } catch (e, stackTrace) {
      state = AsyncValue.error('Failed to save progress: $e', stackTrace);
    }
  }

  // Method to update user goals - Corrected signature and logic
  Future<void> updateGoals({
    required String goalType, // Changed from fitnessGoal
    required double targetWeight,
    required DateTime targetDate, // Added targetDate
  }) async {
    state = const AsyncValue.loading();
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }

    try {
      // Use upsert to insert or update based on user_id in the 'goals' table
      await _supabaseClient.from('goals').upsert({
        'user_id': user.id,
        'goal_type': goalType, // Use goalType
        'target_weight': targetWeight,
        'target_date': targetDate.toIso8601String(), // Use targetDate
        'updated_at': DateTime.now().toIso8601String(), // Track last update
      }, onConflict: 'user_id'); // Specify the column for conflict resolution

      state = const AsyncValue.data(null); // Success
    } catch (e, stackTrace) {
      state = AsyncValue.error('Failed to update goals: $e', stackTrace);
    }
  }
}

// Provider for the ProgressController
final progressControllerProvider =
    StateNotifierProvider<ProgressController, AsyncValue<void>>((ref) {
      return ProgressController();
    });
