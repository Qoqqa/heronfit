import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart';
import 'package:solar_icons/solar_icons.dart';
// ADDED: Import notifications controller and any necessary models
// MODIFIED: Added prefix to import for notifications controller to avoid name conflict
import 'package:heronfit/features/notifications/controllers/notifications_controller.dart'
    as controller;
// ADDED: Import for timeago package (assuming it's used or will be added)
// import 'package:timeago/timeago.dart' as timeago;
// ADDED: Import for GoRouter
import 'package:go_router/go_router.dart';
// ADDED: Import for AppRoutes
import 'package:heronfit/core/router/app_routes.dart';

class NotificationListItem extends ConsumerWidget {
  const NotificationListItem({super.key, required this.notification});

  final controller.Notification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Assuming 'title', 'body', 'created_at', and 'is_read' keys exist
    final title = notification.title;
    final body = notification.body;
    final timestamp = notification.createdAt;
    final isRead = notification.isRead;

    // Determine icon based on notification type or other data (TODO: refine this)
    IconData leadingIcon = SolarIconsBold.bell;
    // Example: if notification['type'] == 'booking_success' leadingIcon = SolarIconsBold.checkCircle;
    // Example: if notification['type'] == 'alert' leadingIcon = SolarIconsBold.dangerCircle;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 12.0, // Increased vertical margin for separation
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0, // Uniform horizontal padding around content
        vertical: 8.0, // Uniform vertical padding around content
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.5),
            width: 1.0,
          ),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0), // Padding around the icon
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(leadingIcon, color: Colors.white, size: 24.0),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatRelativeDate(timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (String value) {
            // TODO: Implement controller calls for actions
            final notificationsNotifier = ref.read(
              controller.notificationsProvider.notifier,
            );

            if (value == 'read') {
              notificationsNotifier.markAsRead(notification.id);
            } else if (value == 'delete') {
              notificationsNotifier.deleteNotification(notification.id);
            } else if (value == 'view_details') {
              context.push('${AppRoutes.notifications}/${notification.id}');
            }
          },
          itemBuilder: (BuildContext context) {
            return <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'view_details',
                child: Text('View Details'),
              ),
              const PopupMenuItem<String>(
                value: 'read',
                child: Text('Mark as Read'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ];
          },
        ),
      ),
    );
  }

  // Helper function to format timestamp to relative date
  String _formatRelativeDate(dynamic timestamp) {
    if (timestamp == null) {
      return 'No timestamp';
    }

    try {
      // Assuming timestamp is a String that can be parsed
      final DateTime dateTime = timestamp;
      // TODO: Implement proper relative date formatting (e.g., using timeago package)
      // For now, a simple representation:
      final Duration diff = DateTime.now().difference(dateTime);
      if (diff.inMinutes < 1) {
        return 'Just now';
      } else if (diff.inHours < 1) {
        return '${diff.inMinutes} minutes ago';
      } else if (diff.inDays < 1) {
        return '${diff.inHours} hours ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        // Fallback to a simple date format
        return '${dateTime.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][dateTime.month - 1]} ${dateTime.year}';
      }
    } catch (e) {
      print('Error parsing timestamp: $e');
      return 'Invalid timestamp';
    }
  }
}
