import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ADDED: NotificationType enum to distinguish between notification and announcement
enum NotificationType { user, announcement }

// MODIFIED: Notification model class
class Notification {
  final String id;
  final String userId; // For announcements, can be empty
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;
  final NotificationType type;
  final DateTime scheduledTime; // NEW: scheduled time for notification/announcement

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.type,
    required this.scheduledTime, // NEW
  });

  // Factory for user notification
  factory Notification.fromMap(Map<String, dynamic> map) {
    final publishedAtStr = map['published_at'] as String?;
    final createdAt = DateTime.parse(map['created_at'] as String);
    final publishedAt = publishedAtStr != null ? DateTime.parse(publishedAtStr) : createdAt;
    return Notification(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      createdAt: createdAt,
      isRead: map['is_read'] as bool? ?? false,
      type: NotificationType.user,
      scheduledTime: publishedAt, // Use published_at for scheduling
    );
  }

  // Factory for announcement
  factory Notification.fromAnnouncement(Map<String, dynamic> map) {
    final publishedAtStr = map['published_at'] as String?;
    final createdAt = DateTime.parse(map['created_at'] as String);
    final publishedAt = publishedAtStr != null ? DateTime.parse(publishedAtStr) : createdAt;
    return Notification(
      id: map['id'] as String,
      userId: '',
      title: map['title'] as String,
      body: map['content'] as String, // FIXED: use 'content' for announcements
      createdAt: createdAt,
      isRead: true, // Announcements are always read
      type: NotificationType.announcement,
      scheduledTime: publishedAt, // Use published_at for scheduling
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
    _fetchNotifications();
  }

  final supabase = Supabase.instance.client;

  Future<void> _fetchNotifications() async {
    try {
      final currentUser = supabase.auth.currentUser;
      final now = DateTime.now().toUtc(); // Use UTC for consistency
      List<Notification> notifications = [];
      if (currentUser != null) {
        final response = await supabase
            .from('notifications')
            .select()
            .eq('user_id', currentUser.id)
            .order('created_at', ascending: false);
        final List<dynamic> data = response as List<dynamic>;
        notifications = data
            .map((item) => Notification.fromMap(item as Map<String, dynamic>))
            .where((n) => n.scheduledTime.toUtc().isBefore(now) || n.scheduledTime.toUtc().isAtSameMomentAs(now))
            .toList();
      }
      final announcementResponse = await supabase
          .from('announcements')
          .select()
          .order('created_at', ascending: false);
      final List<dynamic> announcementData = announcementResponse as List<dynamic>;
      final announcements = announcementData
          .map((item) => Notification.fromAnnouncement(item as Map<String, dynamic>))
          .where((n) => n.scheduledTime.toUtc().isBefore(now) || n.scheduledTime.toUtc().isAtSameMomentAs(now))
          .toList();
      final allItems = [...notifications, ...announcements];
      allItems.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
      state = AsyncValue.data(allItems);
    } catch (e) {
      print('Error fetching notifications/announcements: $e');
      state = AsyncValue.error(e, StackTrace.current);
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
                type: notification.type, // Preserve the type
                scheduledTime: notification.scheduledTime, // Preserve the scheduled time
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
    } catch (e) {
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
    } catch (e) {
      print('Error deleting notification: $e');
      // TODO: Handle error (e.g., revert optimistic update, show error message)
      // For now, just print the error
    }
  }
}
