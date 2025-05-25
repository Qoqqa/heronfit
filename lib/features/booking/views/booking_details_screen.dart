import 'package:flutter/material.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/booking/models/booking_model.dart';
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart'; 
import 'package:heronfit/core/router/app_routes.dart'; 
import 'package:go_router/go_router.dart'; 

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

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
    final String formattedDate = dateFormat.format(booking.sessionDate);
    
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

    final String sessionTime = '${formatSessionTime(booking.sessionStartTime)} - ${formatSessionTime(booking.sessionEndTime)}'; 
    
    final String ticketIdDisplay = booking.userTicketId ?? 'N/A';
    final String bookingRefIdDisplay = booking.bookingReferenceId ?? 'N/A';
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
                      'Session: ${booking.sessionCategory}', 
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
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(SolarIconsOutline.notebook, size: 20),
                label: const Text('View My Bookings'),
                onPressed: () {
                  context.go(AppRoutes.bookings); 
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
