import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/booking/models/session_model.dart';
import 'package:heronfit/features/booking/models/user_ticket_model.dart';
import 'package:heronfit/features/booking/controllers/booking_providers.dart';
import 'package:intl/intl.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

class ReviewBookingScreen extends ConsumerWidget {
  final Session session;
  final DateTime selectedDay;
  final UserTicket? activatedTicket;
  final bool noTicketMode;

  const ReviewBookingScreen({
    super.key,
    required this.session,
    required this.selectedDay,
    this.activatedTicket,
    this.noTicketMode = false,
  });

  Widget _buildSummaryRow(BuildContext context, {required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: HeronFitTheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Poppins',
                    color: HeronFitTheme.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateFormat dateFormat = DateFormat('EEEE - MMMM d, yyyy');
    final String formattedDate = dateFormat.format(selectedDay);
    final String sessionTime = '${session.startTime.format(context)} - ${session.endTime.format(context)}';
    final int availableSlots = session.capacity - session.bookedSlots;

    // Listen to the confirmBookingNotifierProvider for state changes (e.g., success/error)
    ref.listen<AsyncValue<Map<String, dynamic>?>>(confirmBookingNotifierProvider, (_, state) {
      state.when(
        data: (bookingDetails) {
          if (bookingDetails != null) {
            // Booking was successful (notifier holds the booking details)
            _showSessionConfirmedModal(context, bookingDetails); // Pass bookingDetails
            // Optionally, reset the notifier state if you want it to be ready for another booking attempt
            // without navigating away, though typically navigation occurs.
            // ref.read(confirmBookingNotifierProvider.notifier).resetState(); // You'd need to add resetState method
          }
          // If bookingDetails is null, it means initial state or reset, do nothing here.
        },
        loading: () {
          // Loading state is handled by the button's appearance
        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking failed: ${error.toString()}'), backgroundColor: Colors.red),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            SolarIconsOutline.altArrowLeft,
            color: HeronFitTheme.primary,
            size: 28,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Review Booking Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: HeronFitTheme.primary,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please review your booking details below before confirming. Make sure all the information is correct.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HeronFitTheme.textSecondary,
                    fontFamily: 'Poppins',
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Booking Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: HeronFitTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: HeronFitTheme.cardShadow,
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSummaryRow(context, icon: SolarIconsOutline.ticket, text: 'Ticket ID: ${activatedTicket?.ticketCode ?? 'N/A'}'),
                    _buildSummaryRow(context, icon: SolarIconsOutline.calendar, text: 'Date: $formattedDate'),
                    _buildSummaryRow(context, icon: SolarIconsOutline.clockCircle, text: 'Time: $sessionTime'),
                    _buildSummaryRow(context, icon: SolarIconsOutline.usersGroupRounded, text: 'Capacity: $availableSlots/${session.capacity} spots left'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Consumer( // Use Consumer to get specific ref for the button
                builder: (context, buttonRef, child) {
                  final confirmBookingState = buttonRef.watch(confirmBookingNotifierProvider);
                  return FilledButton(
                    onPressed: confirmBookingState.isLoading ? null : () async {
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error: User not authenticated.')),
                        );
                        return;
                      }

                      final String formattedSessionDate = DateFormat('yyyy-MM-dd').format(selectedDay);
                      final String formattedStartTime = DateFormat('HH:mm:ss').format(
                        DateTime(selectedDay.year, selectedDay.month, selectedDay.day, session.startTime.hour, session.startTime.minute)
                      ); 
                      final String formattedEndTime = DateFormat('HH:mm:ss').format(
                        DateTime(selectedDay.year, selectedDay.month, selectedDay.day, session.endTime.hour, session.endTime.minute)
                      );

                      // Call the notifier to book the session
                      await buttonRef.read(confirmBookingNotifierProvider.notifier).bookSession(
                        sessionId: session.id,
                        activatedTicketId: activatedTicket?.id, 
                        sessionDate: formattedSessionDate,
                        sessionStartTime: formattedStartTime,
                        sessionEndTime: formattedEndTime,
                        sessionCategory: session.category,
                      );
                      // Success/error is handled by the ref.listen above
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: HeronFitTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                    ),
                    child: confirmBookingState.isLoading 
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                        : const Text('Confirm Booking'),
                  );
                }
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: HeronFitTheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: HeronFitTheme.primary,
                      ),
                ),
                child: const Text('Change Session'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSessionConfirmedModal(BuildContext context, Map<String, dynamic> bookingDetails) { // Added bookingDetails param
    // Parse details from the bookingDetails map for display in the modal if needed
    // For example, if you want to show the specific booking reference ID in the modal.
    // final confirmedBooking = Booking.fromJson(bookingDetails); // If you need Booking object here

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            'Session Confirmed!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Poppins', color: HeronFitTheme.primary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Your gym session is booked for ${DateFormat('MMMM d, yyyy').format(selectedDay)} at ${session.timeRangeShort}!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins'),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: HeronFitTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: Text(
                  'View Booking Details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.pushNamed(
                    AppRoutes.bookingDetails,
                    extra: bookingDetails, // Pass the actual bookingDetails map
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
