import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/progress/models/progress_record.dart'; // Use the model definition
import 'package:image_picker/image_picker.dart'; // Import image_picker for XFile
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Provider to fetch progress records (weight history, photos)
final progressRecordsProvider =
    StateNotifierProvider<ProgressNotifier, AsyncValue<List<ProgressRecord>>>((
      ref,
    ) {
      return ProgressNotifier(ref);
    });

class ProgressNotifier extends StateNotifier<AsyncValue<List<ProgressRecord>>> {
  final Ref _ref;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  ProgressNotifier(this._ref) : super(const AsyncValue.loading()) {
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
      print('Error fetching progress records: $e');
    }
  }

  Future<void> addWeightEntry(double weight, String? picUrl) async {
    // Implementation for adding weight entry
  }
}

// Provider for user goals
final userGoalsProvider =
    StateNotifierProvider<UserGoalsNotifier, AsyncValue<UserGoal?>>((ref) {
      return UserGoalsNotifier(ref);
    });

class UserGoalsNotifier extends StateNotifier<AsyncValue<UserGoal?>> {
  final Ref _ref;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  UserGoalsNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchUserGoals();
  }

  Future<void> fetchUserGoals() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }
      final response =
          await _supabaseClient
              .from('user_goals') // Verified 'user_goals' table name
              .select()
              .eq('user_id', userId)
              .maybeSingle(); // Use maybeSingle if a user has at most one goal entry

      if (response != null) {
        // Use UserGoal.fromJson from the model
        state = AsyncValue.data(
          UserGoal.fromJson(response as Map<String, dynamic>),
        );
      } else {
        state = const AsyncValue.data(null); // No goals found
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Consider logging the error
      print('Error fetching user goals: $e');
    }
  }

  Future<void> updateGoals(
    String goalType,
    double targetWeight,
    DateTime targetDate,
  ) async {
    final currentState = state; // Read current state safely
    if (currentState is! AsyncData<UserGoal?>) {
      // Avoid updating if not in data state (or handle loading/error appropriately)
      return;
    }

    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Use the UserGoal constructor from the model
      final goalDataMap = {
        'user_id': userId,
        'goal_type': goalType,
        'target_weight': targetWeight,
        'target_date': targetDate.toIso8601String(),
      };

      // Use upsert to either insert a new goal or update an existing one
      final response =
          await _supabaseClient
              .from('user_goals') // Verified 'user_goals' table name
              .upsert(goalDataMap, onConflict: 'user_id')
              .select() // Select the upserted/updated row
              .single(); // Expect a single row back

      // Update local state with the data returned from the DB
      state = AsyncValue.data(UserGoal.fromJson(response));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      print('Error updating user goals: $e');
      rethrow; // Rethrow to allow UI to handle error
    }
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

  // Method to update user goals
  Future<void> updateGoals({
    required double targetWeight,
    required double targetBodyFatPercentage,
    required String fitnessGoal, // e.g., 'Lose Weight', 'Gain Muscle'
  }) async {
    state = const AsyncValue.loading();
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }

    try {
      // Use upsert to insert or update based on user_id
      await _supabaseClient.from('user_goals').upsert({
        'user_id': user.id,
        'target_weight': targetWeight,
        'target_body_fat_percentage': targetBodyFatPercentage,
        'fitness_goal': fitnessGoal,
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
