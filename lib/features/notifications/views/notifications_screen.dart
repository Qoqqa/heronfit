import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/notifications/controllers/notifications_controller.dart';
import 'package:solar_icons/solar_icons.dart';
// ADDED: Import for timeago package (assuming it's used or will be added)
// import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notificationsAsyncValue = ref.watch(notificationsProvider);

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
            // TODO: Display the list of notifications
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                // Assuming 'title', 'body', and 'created_at' keys exist
                final title = notification['title'] ?? 'No Title';
                final body = notification['body'] ?? ''; // Body can be empty
                final timestamp = notification['created_at'];

                // Determine icon based on notification type or other data (TODO: refine this)
                IconData leadingIcon = SolarIconsBold.bell;
                // Example: if notification['type'] == 'booking_success' leadingIcon = SolarIconsBold.checkCircle;
                // Example: if notification['type'] == 'alert' leadingIcon = SolarIconsBold.dangerCircle;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: HeronFitTheme.cardShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          leadingIcon,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                      title: Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _formatRelativeDate(timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          print('More options tapped for notification: $title');
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
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
      final DateTime dateTime = DateTime.parse(timestamp.toString());
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
