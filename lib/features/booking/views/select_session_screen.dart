import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/booking/models/session_model.dart';
import 'package:heronfit/features/booking/controllers/booking_providers.dart'; // Import new providers
import 'package:heronfit/features/booking/models/user_ticket_model.dart'; // Import UserTicket model
import 'package:table_calendar/table_calendar.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart'; // For date formatting

// Provider for selected day
final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
// Provider for focused day (for calendar controls)
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

class SelectSessionScreen extends ConsumerWidget {
  final UserTicket? activatedTicket; // Made nullable
  final bool noTicketMode;          // Added flag

  const SelectSessionScreen({
    super.key, 
    this.activatedTicket, 
    this.noTicketMode = false, // Default to false
  });

  void _showJoinWaitlistDialog(BuildContext context, WidgetRef ref, Session session) { // Added WidgetRef
    // To handle loading state within the dialog or on the button
    // We can use a local state variable if the dialog rebuilds, 
    // or manage it via the notifier's state if the dialog is simple.
    // For now, let's keep it simple and show feedback via Snackbars after pop.

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Join Waitlist?', style: Theme.of(context).textTheme.titleLarge),
          content: Text('This session (${session.startTime.format(dialogContext)}) is currently full. Would you like to join the waitlist?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Find Another Session'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            Consumer( // Use Consumer to access ref for the ElevatedButton
              builder: (context, innerRef, child) {
                final joinWaitlistState = innerRef.watch(joinWaitlistNotifierProvider);
                return ElevatedButton(
                  child: joinWaitlistState.isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Yes, Join Waitlist'),
                  onPressed: joinWaitlistState.isLoading ? null : () async {
                    try {
                      await innerRef.read(joinWaitlistNotifierProvider.notifier).join(session.id, activatedTicket?.id);
                      Navigator.of(dialogContext).pop(); // Close the dialog on success
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Successfully joined the waitlist for ${session.startTime.format(dialogContext)}.')),
                      );
                    } catch (e) {
                      Navigator.of(dialogContext).pop(); // Close the dialog on error too
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to join waitlist: ${e.toString()}'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: HeronFitTheme.primary, foregroundColor: Colors.white),
                );
              }
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
              decoration: cardDecoration.copyWith(color: colorScheme.surface), // Use surface color from theme
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  locale: 'en_US',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  calendarFormat: CalendarFormat.week, // Changed to week view
                  availableCalendarFormats: const {CalendarFormat.week: 'Week'}, // Only allow week view
                  onDaySelected: (newSelectedDay, newFocusedDay) {
                    ref.read(selectedDayProvider.notifier).state = newSelectedDay;
                    ref.read(focusedDayProvider.notifier).state = newFocusedDay; // Update focusedDay as well
                  },
                  onPageChanged: (newFocusedDay) {
                    ref.read(focusedDayProvider.notifier).state = newFocusedDay;
                  },
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false, // Hide format button as we only want week view
                    titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: HeronFitTheme.primary), // Use titleMedium
                    leftChevronIcon: const Icon(Icons.chevron_left, color: HeronFitTheme.primary),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: HeronFitTheme.primary),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: HeronFitTheme.primaryDark.withOpacity(0.5), // Corrected: Was secondaryColor
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: HeronFitTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    // Add styling for weekend days if needed
                    weekendTextStyle: TextStyle(color: Colors.grey[600]),
                    // Styling for days outside the current month (less relevant for week view but good practice)
                    outsideDaysVisible: false, 
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500), // Style for Mon-Fri
                    weekendStyle: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),   // Style for Sat-Sun
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Available Sessions - ${titleDateFormat.format(selectedDay)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: HeronFitTheme.textPrimary), // Corrected: Was primaryText
            ),
            const SizedBox(height: 10),
            Expanded(
              child: sessionsAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return const Center(
                      child: Text(
                        'No sessions available for this day.',
                        style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Poppins'),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return Card(
                        elevation: 2.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(SolarIconsOutline.clockCircle, size: 20, color: HeronFitTheme.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          session.timeRangeShort, // Using the getter from Session model
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                      ],
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
                                    _showJoinWaitlistDialog(context, ref, session); // Pass ref
                                  } else {
                                    // Navigate to Review Booking Screen
                                    context.pushNamed(
                                      AppRoutes.reviewBooking,
                                      extra: {
                                        'session': session, 
                                        'selectedDay': selectedDay,
                                        'activatedTicket': activatedTicket, // Pass the potentially null ticket
                                        'noTicketMode': noTicketMode,     // Pass the flag
                                      },
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
