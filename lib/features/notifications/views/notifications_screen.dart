import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart';
import 'package:solar_icons/solar_icons.dart';
// ADDED: Import for the new notification list item widget
import 'package:heronfit/features/notifications/widgets/notification_list_item.dart';

// ADDED: Import notifications provider
// MODIFIED: Added prefix to import for notifications controller to avoid name conflict
import 'package:heronfit/features/notifications/controllers/notifications_controller.dart'
    as controller;
// ADDED: Import for timeago package (assuming it's used or will be added)
// import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notificationsAsyncValue = ref.watch(controller.notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: HeronFitTheme.primary,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: HeronFitTheme.primary),
        ),
      ),
      body: notificationsAsyncValue.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      SolarIconsBold
                          .bellOff, // Using bell_off as it seems to be the correct icon name
                      size: 64.0,
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'No New Notifications',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'You\’re all caught up! Check back later for new updates.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                // Pass notification object as extra for details screen
                return NotificationListItem(notification: notification);
              },
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
      ),
    );
  }

  // Helper function to format timestamp to relative date (Moved to NotificationListItem)
  // String _formatRelativeDate(dynamic timestamp) { /* ... */ }
}

// Moved to notification_list_item.dart
/*
class NotificationListItem extends ConsumerWidget { /* ... */ }
*/
