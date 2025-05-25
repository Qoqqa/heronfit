import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/booking/models/session_model.dart';
import 'package:heronfit/features/booking/controllers/booking_providers.dart'; // Import new providers
import 'package:table_calendar/table_calendar.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart'; // For date formatting

// Provider for selected day
final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
// Provider for focused day (for calendar controls)
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

class SelectSessionScreen extends ConsumerWidget {
  const SelectSessionScreen({super.key});

  void _showJoinWaitlistDialog(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Join Waitlist?', style: Theme.of(context).textTheme.titleLarge),
          content: Text('This session (${session.startTime.format(context)}) is currently full. Would you like to join the waitlist?'),
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
                  SnackBar(content: Text('You have been added to the waitlist for ${session.startTime.format(context)}.')),
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
    final DateTime selectedDay = ref.watch(selectedDayProvider);
    final DateTime focusedDay = ref.watch(focusedDayProvider);
    final AsyncValue<List<Session>> sessionsAsync = ref.watch(fetchSessionsProvider(selectedDay));
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
            const SizedBox(height: 8), // Added some top spacing
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Location: University of Makati HPSB 11th Floor Gym',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: HeronFitTheme.textSecondary, // Or another appropriate color
                ),
                textAlign: TextAlign.center,
              ),
            ),
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
              child: sessionsAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return const Center(
                      child: Text(
                        'No sessions available for this day.',
                        style: TextStyle(fontSize: 16, color: HeronFitTheme.textSecondary, fontFamily: 'Poppins'),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
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
                                          // Format start and end times
                                          '${session.startTime.format(context)} - ${session.endTime.format(context)}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text( // Display category
                                      session.category,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: HeronFitTheme.textSecondary, fontStyle: FontStyle.italic),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(SolarIconsOutline.usersGroupRounded, size: 18, color: (session.bookedSlots >= session.capacity) ? Colors.redAccent : Colors.green),
                                        const SizedBox(width: 8),
                                        Text(
                                          (session.bookedSlots >= session.capacity) ? 'Full' : '${session.capacity - session.bookedSlots}/${session.capacity} spots',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: (session.bookedSlots >= session.capacity) ? Colors.redAccent : Colors.green, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Updated logic: remove facultyOnly check, use bookedSlots >= capacity for isFull
                                  if ((session.bookedSlots >= session.capacity)) {
                                    _showJoinWaitlistDialog(context, session);
                                  } else {
                                    // Navigate to Review Booking Screen
                                    context.pushNamed(
                                      AppRoutes.reviewBooking,
                                      extra: {'session': session, 'selectedDay': selectedDay},
                                    );
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
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error loading sessions: ${error.toString()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontFamily: 'Poppins'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
