import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Define a provider to fetch notifications for the current user
final notificationsProvider = FutureProvider((ref) async {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;

  if (currentUser == null) {
    // Handle case where user is not logged in
    return [];
  }

  try {
    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', currentUser.id)
        .order('created_at', ascending: false);

    // Assuming your notifications table returns a list of maps
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      response,
    );

    // TODO: Map the data to a Notification model if you create one
    return data;
  } catch (e) {
    // Handle errors, e.g., logging or showing a user-friendly message
    print('Error fetching notifications: $e');
    throw e; // Re-throw the error for the UI to handle
  }
});
