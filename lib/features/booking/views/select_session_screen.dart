import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:heronfit/core/theme.dart'; // Assuming your theme is here
import 'package:intl/intl.dart'; // For date formatting

// Mock data for sessions - replace with actual data fetching later
class Session {
  final String time;
  final int availableSlots;
  final int totalSlots;
  final bool isFull;
  final bool facultyOnly;

  Session({
    required this.time,
    required this.availableSlots,
    required this.totalSlots,
    this.facultyOnly = false,
  }) : isFull = availableSlots == 0;
}

// Provider for selected day
final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
// Provider for focused day (for calendar controls)
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Updated mockSessionsProvider to reflect new logic
final sessionsForDateProvider = Provider.family<List<Session>, DateTime>((ref, date) {
  // Simulate fetching sessions for a specific date
  // Gym operates Mon-Fri. This is partially handled by calendar's enabledDayPredicate.
  // For mock purposes, we'll return sessions if it's a weekday.
  if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
    return []; // No sessions on weekends
  }

  // Example: Different sessions or availability based on the day of the week or specific date
  // For simplicity, returning a fixed list for any valid weekday for now.
  return [
    Session(time: '8:00 AM - 10:00 AM', availableSlots: 10, totalSlots: 15),
    Session(time: '10:00 AM - 12:00 PM', availableSlots: 0, totalSlots: 15),
    Session(time: '12:00 PM - 2:00 PM', availableSlots: 5, totalSlots: 15),
    Session(time: '2:00 PM - 4:00 PM', availableSlots: 15, totalSlots: 15),
    Session(time: '4:00 PM - 6:30 PM', availableSlots: 8, totalSlots: 10, facultyOnly: true),
  ];
});

class SelectSessionScreen extends ConsumerWidget {
  const SelectSessionScreen({super.key});

  void _showFacultyOnlyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Session Restricted', style: Theme.of(context).textTheme.titleLarge),
          content: const Text('This session is exclusively for UMak employees and faculty. Please select another session if you are not an employee or faculty member.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showJoinWaitlistDialog(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Join Waitlist?', style: Theme.of(context).textTheme.titleLarge),
          content: Text('This session (${session.time}) is currently full. Would you like to join the waitlist?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Find Another Session'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: const Text('Yes, Join Waitlist'),
              onPressed: () {
                // Implement waitlist logic here
                Navigator.of(dialogContext).pop(); // Close the dialog
                // Show a confirmation (e.g., SnackBar)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You have been added to the waitlist for ${session.time}.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: HeronFitTheme.primary, foregroundColor: Colors.white),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);
    // Fetch sessions for the currently selected day
    final sessions = ref.watch(sessionsForDateProvider(selectedDay));
    final DateFormat titleDateFormat = DateFormat('MMMM d, yyyy'); // e.g., October 8, 2023
    final colorScheme = Theme.of(context).colorScheme;

    // Common card styling
    final cardDecoration = BoxDecoration(
      color: colorScheme.background,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: HeronFitTheme.cardShadow, // Assuming this is a List<BoxShadow>
    );

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
        title: Text(
          'Book a Session', // Title from previous iteration
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: HeronFitTheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16.0, top: 8.0),
              decoration: cardDecoration,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 30)), // Allow selecting previous days for viewing, but booking logic should prevent it
                  lastDay: DateTime.now().add(const Duration(days: 60)),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  enabledDayPredicate: (day) {
                    // Disable weekends
                    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
                      return false;
                    }
                    return true;
                  },
                  onDaySelected: (newSelectedDay, newFocusedDay) {
                    ref.read(selectedDayProvider.notifier).state = newSelectedDay;
                    ref.read(focusedDayProvider.notifier).state = newFocusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: HeronFitTheme.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: HeronFitTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    disabledTextStyle: TextStyle(color: Colors.grey.shade400),
                    outsideDaysVisible: false,
                    // Use Poppins for calendar text if available through theme, otherwise default
                    defaultTextStyle: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(), 
                    weekendTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent) ?? const TextStyle(color: Colors.redAccent),
                    holidayTextStyle: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
                    selectedTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white) ?? const TextStyle(color: Colors.white),
                    todayTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: HeronFitTheme.primary) ?? TextStyle(color: HeronFitTheme.primary),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(),
                    leftChevronIcon: const Icon(Icons.chevron_left, color: HeronFitTheme.primary),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: HeronFitTheme.primary),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Available Sessions - ${titleDateFormat.format(selectedDay)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: sessions.isEmpty
                  ? Center(
                      child: Text(
                        selectedDay.weekday == DateTime.saturday || selectedDay.weekday == DateTime.sunday
                          ? 'Gym is closed on weekends.'
                          : 'No sessions available for this day.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: cardDecoration,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(SolarIconsOutline.clockCircle, size: 18, color: HeronFitTheme.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(
                                      session.time,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(SolarIconsOutline.usersGroupRounded, size: 18, color: session.isFull ? Colors.redAccent : Colors.green),
                                    const SizedBox(width: 8),
                                    Text(
                                      session.isFull ? 'Full' : '${session.availableSlots}/${session.totalSlots} spots',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: session.isFull ? Colors.redAccent : Colors.green, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (session.facultyOnly) {
                                _showFacultyOnlyDialog(context);
                              } else if (session.isFull) {
                                _showJoinWaitlistDialog(context, session);
                              } else {
                                // Navigate to Review Booking Screen
                                // context.push(AppRoutes.reviewBooking, extra: sessionDetails);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HeronFitTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text('Book', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
