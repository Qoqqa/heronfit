import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/booking/models/session_model.dart';
import 'package:heronfit/features/booking/controllers/booking_providers.dart'; // Import new providers
import 'package:heronfit/features/booking/models/user_ticket_model.dart'; // Import UserTicket model
import 'package:heronfit/features/booking/models/booking_model.dart'; // Import Booking model
import 'package:table_calendar/table_calendar.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart'; // For date formatting

// Provider for selected day
final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
// Provider for focused day (for calendar controls)
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

class SelectSessionScreen extends ConsumerStatefulWidget {
  final UserTicket? activatedTicket; // Made nullable
  final bool noTicketMode; // Added flag

  const SelectSessionScreen({
    super.key,
    this.activatedTicket,
    this.noTicketMode = false, // Default to false
  });

  @override
  ConsumerState<SelectSessionScreen> createState() =>
      _SelectSessionScreenState();
}

class _SelectSessionScreenState extends ConsumerState<SelectSessionScreen> {
  bool _hasCheckedActiveBooking = false;
  bool _hasActiveBooking = false;
  bool _hasShownActiveBookingDialog = false;

  @override
  void initState() {
    super.initState();
    // Check for active bookings when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForActiveBooking();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh the active booking check when the screen becomes active again
    if (mounted && _hasCheckedActiveBooking) {
      _checkForActiveBooking();
    }
  }

  Future<void> _checkForActiveBooking() async {
    try {
      print('[SelectSessionScreen] Checking for active bookings...');
      final activeBooking = await ref.read(userActiveBookingProvider.future);
      print(
        '[SelectSessionScreen] Active booking check result: ${activeBooking != null ? 'Found booking' : 'No active booking'}',
      );

      if (activeBooking != null && mounted) {
        print('[SelectSessionScreen] Setting _hasActiveBooking to true');
        setState(() {
          _hasActiveBooking = true;
          _hasCheckedActiveBooking = true;
        });

        // Show the active booking dialog if it hasn't been shown yet
        // or if it's being triggered by the Book button (reset flag)
        if (!_hasShownActiveBookingDialog) {
          print('[SelectSessionScreen] Showing active booking dialog');
          _showActiveBookingDialog(activeBooking);
        }
      } else if (mounted) {
        print('[SelectSessionScreen] Setting _hasActiveBooking to false');
        setState(() {
          _hasActiveBooking = false;
          _hasCheckedActiveBooking = true;
          _hasShownActiveBookingDialog =
              false; // Reset flag if no active booking
        });
      }
    } catch (e) {
      print('[SelectSessionScreen] Error checking for active bookings: $e');
      if (mounted) {
        setState(() {
          _hasCheckedActiveBooking = true;
          // Default to true if there's an error, to be safe
          _hasActiveBooking = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking active bookings: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showActiveBookingDialog(Booking activeBooking) {
    if (!mounted) return;

    // Set flag to indicate dialog has been shown
    setState(() {
      _hasShownActiveBookingDialog = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Active Booking Exists'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You already have an active booking for ${DateFormat('MMMM d, yyyy').format(activeBooking.sessionDate)} at ${activeBooking.sessionTimeRangeShort}.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please cancel your current booking or wait for it to complete before booking another session.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('View My Bookings'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push(AppRoutes.bookings);
              },
            ),
            TextButton(
              child: const Text('Go Back'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(); // Go back to previous screen
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
          title: Text(
            'Join Waitlist?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'This session (${session.startTime.format(dialogContext)}) is currently full. Would you like to join the waitlist?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Find Another Session'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            Consumer(
              // Use Consumer to access ref for the ElevatedButton
              builder: (context, innerRef, child) {
                final joinWaitlistState = innerRef.watch(
                  joinWaitlistNotifierProvider,
                );
                return ElevatedButton(
                  child:
                      joinWaitlistState.isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Yes, Join Waitlist'),
                  onPressed:
                      joinWaitlistState.isLoading
                          ? null
                          : () async {
                            try {
                              await innerRef
                                  .read(joinWaitlistNotifierProvider.notifier)
                                  .join(session.id, widget.activatedTicket?.id);
                              Navigator.of(
                                dialogContext,
                              ).pop(); // Close the dialog on success
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Successfully joined the waitlist for ${session.startTime.format(dialogContext)}.',
                                  ),
                                ),
                              );
                            } catch (e) {
                              Navigator.of(
                                dialogContext,
                              ).pop(); // Close the dialog on error too
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to join waitlist: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeronFitTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime selectedDay = ref.watch(selectedDayProvider);
    final DateTime focusedDay = ref.watch(focusedDayProvider);
    final AsyncValue<List<Session>> sessionsAsync = ref.watch(
      fetchSessionsProvider(selectedDay),
    );
    final DateFormat titleDateFormat = DateFormat(
      'MMMM d, yyyy',
    ); // e.g., October 8, 2023
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
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
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

            Container(
              margin: const EdgeInsets.only(bottom: 16.0, top: 8.0),
              decoration: cardDecoration.copyWith(
                color: colorScheme.surface,
              ), // Use surface color from theme
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  locale: 'en_US',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  calendarFormat: CalendarFormat.week, // Changed to week view
                  availableCalendarFormats: const {
                    CalendarFormat.week: 'Week',
                  }, // Only allow week view
                  onDaySelected: (newSelectedDay, newFocusedDay) {
                    ref.read(selectedDayProvider.notifier).state =
                        newSelectedDay;
                    ref.read(focusedDayProvider.notifier).state =
                        newFocusedDay; // Update focusedDay as well
                  },
                  onPageChanged: (newFocusedDay) {
                    ref.read(focusedDayProvider.notifier).state = newFocusedDay;
                  },
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible:
                        false, // Hide format button as we only want week view
                    titleTextStyle: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: HeronFitTheme.primary,
                    ), // Use titleMedium
                    leftChevronIcon: const Icon(
                      Icons.chevron_left,
                      color: HeronFitTheme.primary,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right,
                      color: HeronFitTheme.primary,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: HeronFitTheme.primaryDark.withOpacity(
                        0.5,
                      ), // Corrected: Was secondaryColor
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
                    weekdayStyle: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ), // Style for Mon-Fri
                    weekendStyle: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ), // Style for Sat-Sun
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Available Sessions - ${titleDateFormat.format(selectedDay)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: HeronFitTheme.textPrimary,
              ), // Corrected: Was primaryText
            ),
            const SizedBox(height: 10),
            Expanded(
              child: sessionsAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return const Center(
                      child: Text(
                        'No sessions available for this day.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ), // Original Card margin
                        decoration: BoxDecoration(
                          color:
                              Theme.of(
                                context,
                              ).cardColor, // Use theme's card color for background
                          borderRadius: BorderRadius.circular(
                            12.0,
                          ), // Match Card's shape
                          boxShadow:
                              HeronFitTheme.cardShadow, // Apply custom shadow
                        ),
                        child: Card(
                          elevation:
                              0, // Set elevation to 0 as shadow is handled by Container
                          margin:
                              EdgeInsets.zero, // Margin handled by Container
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          color:
                              Colors
                                  .transparent, // Card is transparent, Container provides background
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            SolarIconsOutline.clockCircle,
                                            size: 20,
                                            color: HeronFitTheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            session
                                                .timeRangeShort, // Using the getter from Session model
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            SolarIconsOutline.usersGroupRounded,
                                            size: 18,
                                            color:
                                                (session.bookedSlots >=
                                                        session.capacity)
                                                    ? Colors.redAccent
                                                    : Colors.green,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            (session.bookedSlots >=
                                                    session.capacity)
                                                ? 'Full'
                                                : '${session.capacity - session.bookedSlots}/${session.capacity} spots',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              color:
                                                  (session.bookedSlots >=
                                                          session.capacity)
                                                      ? Colors.redAccent
                                                      : Colors.green,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Consumer(
                                  builder: (context, ref, _) {
                                    // Always check for active booking before enabling the button
                                    final activeBookingAsync = ref.watch(
                                      userActiveBookingProvider,
                                    );
                                    final hasActiveBooking =
                                        activeBookingAsync.asData?.value !=
                                            null ||
                                        _hasActiveBooking;
                                    return ElevatedButton(
                                      key: const ValueKey('book_button'),
                                      onPressed:
                                          hasActiveBooking
                                              ? null
                                              : () async {
                                                if (!mounted) return;
                                                debugPrint(
                                                  '[SelectSessionScreen] Book button clicked. Checking for active booking...',
                                                );
                                                try {
                                                  // Always refresh before proceeding
                                                  final activeBooking =
                                                      await ref.refresh(
                                                        userActiveBookingProvider
                                                            .future,
                                                      );
                                                  if (!mounted) return;
                                                  if (activeBooking != null) {
                                                    setState(() {
                                                      _hasActiveBooking = true;
                                                      _hasCheckedActiveBooking =
                                                          true;
                                                    });
                                                    _showActiveBookingDialog(
                                                      activeBooking,
                                                    );
                                                    return;
                                                  }
                                                  setState(() {
                                                    _hasActiveBooking = false;
                                                    _hasCheckedActiveBooking =
                                                        true;
                                                  });
                                                  // Check if session is full
                                                  if (session.bookedSlots >=
                                                      session.capacity) {
                                                    _showJoinWaitlistDialog(
                                                      context,
                                                      session,
                                                    );
                                                  } else if (widget
                                                              .activatedTicket !=
                                                          null ||
                                                      widget.noTicketMode) {
                                                    context.pushNamed(
                                                      AppRoutes.reviewBooking,
                                                      extra: {
                                                        'session': session,
                                                        'selectedDay':
                                                            selectedDay,
                                                        'activatedTicket':
                                                            widget
                                                                .activatedTicket,
                                                        'noTicketMode':
                                                            widget.noTicketMode,
                                                      },
                                                    );
                                                  } else {
                                                    context.push(
                                                      AppRoutes.activateGymPass,
                                                    );
                                                  }
                                                } catch (error) {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                          'Error checking booking status. Please try again.',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith<
                                              Color
                                            >((Set<MaterialState> states) {
                                              if (states.contains(
                                                MaterialState.disabled,
                                              )) {
                                                return Colors.grey;
                                              }
                                              return HeronFitTheme.primary;
                                            }),
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                              Colors.white,
                                            ),
                                        shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder
                                        >(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                          ),
                                        ),
                                        padding: MaterialStateProperty.all<
                                          EdgeInsets
                                        >(
                                          const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        hasActiveBooking
                                            ? 'Already Booked'
                                            : 'Book',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading sessions: ${error.toString()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontFamily: 'Poppins',
                          ),
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
