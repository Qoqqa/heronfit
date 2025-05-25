import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ADDED: Notification model class
class Notification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  // Factory constructor to create a Notification from a Supabase map
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ), // Assuming timestamp is a string
      isRead: map['is_read'] as bool? ?? false, // Default to false if null
    );
  }
}

// MODIFIED: Change to StateNotifierProvider
final notificationsProvider = StateNotifierProvider<
  NotificationsNotifier,
  AsyncValue<List<Notification>>
>((ref) {
  return NotificationsNotifier();
});

// ADDED: StateNotifier to manage the notifications list
class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<Notification>>> {
  NotificationsNotifier() : super(const AsyncValue.loading()) {
    _fetchNotifications(); // Fetch notifications when the notifier is created
  }

  final supabase = Supabase.instance.client;

  Future<void> _fetchNotifications() async {
    try {
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        state = const AsyncValue.data(
          [],
        ); // User not logged in, return empty list
        return;
      }

      final response = await supabase
          .from('notifications')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      // Map the data to Notification models
      final notifications =
          data
              .map((item) => Notification.fromMap(item as Map<String, dynamic>))
              .toList();

      state = AsyncValue.data(notifications);
    } catch (e, stackTrace) {
      print('Error fetching notifications: $e');
      state = AsyncValue.error(e, stackTrace); // Propagate the error
    }
  }

  // ADDED: Method to mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    // Optimistically update the state
    if (state is AsyncData) {
      final currentNotifications = state.asData!.value;
      final updatedNotifications =
          currentNotifications.map((notification) {
            if (notification.id == notificationId) {
              return Notification(
                id: notification.id,
                userId: notification.userId,
                title: notification.title,
                body: notification.body,
                createdAt: notification.createdAt,
                isRead: true, // Mark as read
              );
            } else {
              return notification;
            }
          }).toList();
      state = AsyncValue.data(updatedNotifications);
    }

    try {
      // Update in Supabase
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e, stackTrace) {
      print('Error marking notification as read: $e');
      // TODO: Handle error (e.g., revert optimistic update, show error message)
      // For now, just print the error
    }
  }

  // ADDED: Method to delete a notification
  Future<void> deleteNotification(String notificationId) async {
    print('Attempting to delete notification with ID: $notificationId');

    // Optimistically update the state
    if (state is AsyncData) {
      final currentNotifications = state.asData!.value;
      final updatedNotifications =
          currentNotifications
              .where((notification) => notification.id != notificationId)
              .toList();
      state = AsyncValue.data(updatedNotifications);
    }

    try {
      // Delete from Supabase
      await supabase.from('notifications').delete().eq('id', notificationId);
    } catch (e, stackTrace) {
      print('Error deleting notification: $e');
      // TODO: Handle error (e.g., revert optimistic update, show error message)
      // For now, just print the error
    }
  }
}
