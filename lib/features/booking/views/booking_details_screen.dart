import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/booking/models/booking_model.dart';
import 'package:heronfit/features/booking/views/my_bookings.dart';
import 'package:heronfit/features/booking/controllers/booking_providers.dart'; // Import for userActiveBookingProvider
import 'package:heronfit/features/home/home_providers.dart'; // Import for upcomingSessionProvider
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heronfit/features/booking/models/user_ticket_model.dart'; // Import TicketStatus

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final Booking booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  @override
  ConsumerState<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  bool _isCancelling = false;

  // Helper to format time string (HH:mm:ss) to a more readable format (e.g., h:mm a)
  String formatSessionTime(String timeString) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final timeOfDay = TimeOfDay(hour: hour, minute: minute);
      return timeOfDay.format(context);
    } catch (e) {
      return timeString; // Fallback to original string if parsing fails
    }
  }

  bool _isCancellable() {
    final now = DateTime.now();
    final bookingTime = widget.booking.bookingTime;

    // Check if booking status is 'confirmed' and booking was made within the last 2 hours
    return widget.booking.status == BookingStatus.confirmed && 
           now.difference(bookingTime).inHours <= 2;
  }

  Future<void> _cancelBooking() async {
    if (!_isCancellable()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User does not confirm
              },
            ),
            TextButton(
              child: const Text('Yes, Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User confirms
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isCancelling = true;
      });

      try {
        await Supabase.instance.client
            .from('bookings')
            .update({'status': BookingStatus.cancelled_by_user.name}) // Use enum value
            .eq('id', widget.booking.id);

        // Revert ticket status if a ticket was used
        final ticketId = widget.booking.userTicketId;
        if (ticketId != null && ticketId.isNotEmpty) {
          await Supabase.instance.client
              .from('user_tickets')
              .update({
                'status': TicketStatus.available.name,
                'activation_date': null, // Clear activation_date on cancellation
              })
              .eq('id', ticketId)
              // Ensure we are only reverting tickets that were actually used for this booking
              .eq('status', TicketStatus.used.name); 
        }

        ref.invalidate(myBookingsProvider); // Refresh the list of bookings
        ref.invalidate(userActiveBookingProvider); // Refresh the active booking check
        ref.invalidate(upcomingSessionProvider); // Refresh the upcoming session on home screen

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled successfully.')),
          );
          context.go(AppRoutes.home); // Changed from context.pop()
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel booking: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isCancelling = false;
          });
        }
      }
    }
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: HeronFitTheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Poppins',
                        color: HeronFitTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Poppins',
                        color: HeronFitTheme.textPrimary,
                        fontWeight: FontWeight.w600
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(BuildContext context, {required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: HeronFitTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'Poppins',
                    color: HeronFitTheme.textSecondary,
                    height: 1.5
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final String formattedDate = dateFormat.format(widget.booking.sessionDate);

    final String sessionTime = '${formatSessionTime(widget.booking.sessionStartTime)} - ${formatSessionTime(widget.booking.sessionEndTime)}'; 

    final String ticketIdDisplay = widget.booking.userTicketId ?? 'N/A';
    final String bookingRefIdDisplay = widget.booking.bookingReferenceId ?? 'N/A';
    const String gymLocation = "University of Makati HPSB 11th Floor Gym";
    const String cancellationHours = "2";

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
          'Your Booking Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: HeronFitTheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: HeronFitTheme.cardShadow,
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Confirmed',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: HeronFitTheme.primary
                      ),
                    ),
                    const SizedBox(height: 4),
                     Text(
                      'Session: ${widget.booking.sessionCategory}', 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Poppins',
                        color: HeronFitTheme.textSecondary,
                      ),
                    ),
                    const Divider(height: 24, thickness: 1),
                    _buildDetailRow(context, icon: SolarIconsOutline.calendar, label: 'Date', value: formattedDate),
                    _buildDetailRow(context, icon: SolarIconsOutline.clockCircle, label: 'Time', value: sessionTime),
                    _buildDetailRow(context, icon: SolarIconsOutline.mapPoint, label: 'Location', value: gymLocation),
                    _buildDetailRow(context, icon: SolarIconsOutline.document, label: 'Booking Reference ID', value: bookingRefIdDisplay),
                    _buildDetailRow(context, icon: SolarIconsOutline.ticket, label: 'Ticket ID Used', value: ticketIdDisplay),
                    if (widget.booking.status != BookingStatus.confirmed) // Show status if not confirmed
                      _buildDetailRow(context, icon: SolarIconsOutline.infoCircle, label: 'Status', value: widget.booking.status.name.toUpperCase()), // Used .name.toUpperCase()
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Important Instructions Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: HeronFitTheme.cardShadow,
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Important Instructions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: HeronFitTheme.textPrimary
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionRow(context, icon: SolarIconsOutline.usersGroupRounded, text: 'Show this booking confirmation (or your UMak ID) to the front desk upon arrival.'),
                    _buildInstructionRow(context, icon: SolarIconsOutline.alarm, text: 'Please arrive at least 10 minutes before your session to check in.'),
                    _buildInstructionRow(context, icon: SolarIconsOutline.dangerCircle, text: 'You can view or cancel this booking in \'My Bookings\' up to $cancellationHours hours before your session. Please check our cancellation policy for details.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Button
            if (_isCancellable())
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isCancelling 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(SolarIconsOutline.closeCircle, size: 20),
                  label: Text(_isCancelling ? 'Cancelling...' : 'Cancel Booking'),
                  onPressed: _isCancelling ? null : _cancelBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error, // Used Theme.of(context).colorScheme.error
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            // Add spacing if both buttons are potentially visible
            if (_isCancellable()) const SizedBox(height: 12),

            // Always visible Back to Home button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(SolarIconsOutline.home, size: 20), 
                label: const Text('Back to Home'), 
                onPressed: () {
                  context.go(AppRoutes.home); 
                },
                style: FilledButton.styleFrom(
                  backgroundColor: HeronFitTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
