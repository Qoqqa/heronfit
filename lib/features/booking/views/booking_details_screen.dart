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
import 'package:heronfit/features/booking/models/booking_status.dart' as booking_status; // Ensure correct enum is used
import 'package:heronfit/features/booking/services/booking_supabase_service.dart';

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
  Map<String, dynamic>? _ticketData; // Store fetched ticket data
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _fetchTicketData();
  }

  Future<void> _fetchTicketData() async {
    if (widget.booking.userTicketId != null && widget.booking.userTicketId!.isNotEmpty) {
      final data = await Supabase.instance.client
        .from('user_tickets')
        .select('ticket_code')
        .eq('id', widget.booking.userTicketId!)
        .maybeSingle();
      setState(() {
        _ticketData = data;
      });
    } else {
      setState(() {
        _ticketData = null;
      });
    }
  }

  Future<void> _refreshBookingDetails() async {
    setState(() { _isRefreshing = true; });
    // Fetch the latest booking details from Supabase
    final updatedBooking = await Supabase.instance.client
      .from('bookings')
      .select()
      .eq('id', widget.booking.id)
      .maybeSingle();
    if (updatedBooking != null) {
      // Optionally, you could update the widget.booking if you want to support live updates
      // For now, just refresh the ticket data
      await _fetchTicketData();
    }
    setState(() { _isRefreshing = false; });
  }

  // Convert UTC time to Manila time (UTC+8)
  DateTime toManilaTime(DateTime utcTime) {
    return utcTime.toUtc().add(const Duration(hours: 8));
  }

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
    final status = widget.booking.status;
    // Allow cancellation for pending, pending_attendance, pending_receipt_number, and confirmed (within 2 hours)
    return status == booking_status.BookingStatus.pending ||
        status == booking_status.BookingStatus.pending_attendance ||
        status == booking_status.BookingStatus.pending_receipt_number ||
        (status == booking_status.BookingStatus.confirmed && now.difference(bookingTime).inHours <= 2);
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
        final bookingService = ref.read(bookingSupabaseServiceProvider);
        if (widget.booking.sessionOccurrenceId == null || widget.booking.sessionOccurrenceId!.isEmpty) {
          throw Exception('Booking is missing session occurrence ID. Cannot cancel and update slots.');
        }
        await bookingService.cancelBooking(
          bookingId: widget.booking.id,
          sessionOccurrenceId: widget.booking.sessionOccurrenceId!,
          userTicketId: widget.booking.userTicketId,
        );

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

  String _formatStatus(String status) {
    // Replace underscores with spaces and capitalize each word
    return status
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
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

    // Determine the display value for the receipt number
    Widget receiptNumberWidget;
    if (_ticketData != null && _ticketData!['ticket_code'] != null) {
      receiptNumberWidget = Text(_ticketData!['ticket_code'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins', color: HeronFitTheme.textPrimary, fontWeight: FontWeight.w600));
    } else if (widget.booking.userTicketId != null && widget.booking.userTicketId!.isNotEmpty) {
      receiptNumberWidget = const Text('Loading...');
    } else {
      receiptNumberWidget = const Text('N/A');
    }
    // Booking Reference ID: show bookingReferenceId if present, else booking.id
    final String bookingRefIdDisplay = (widget.booking.bookingReferenceId != null && widget.booking.bookingReferenceId!.isNotEmpty)
        ? widget.booking.bookingReferenceId!
        : widget.booking.id;

    // Determine status color
    Color statusColor = HeronFitTheme.textPrimary;
    final statusName = widget.booking.status.name;
    if (statusName == 'cancelled_by_user' || statusName == 'cancelled_by_admin' || statusName == 'no_show') {
      statusColor = Colors.red;
    } else if (statusName == 'confirmed') {
      statusColor = Colors.green;
    }

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
      body: RefreshIndicator(
        onRefresh: _refreshBookingDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                        _formatStatus(widget.booking.status.name),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(SolarIconsOutline.ticket, color: HeronFitTheme.primary, size: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Receipt Number Used',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontFamily: 'Poppins',
                                          color: HeronFitTheme.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Always show the ticket_code, never the UUID
                                  _ticketData != null && _ticketData!['ticket_code'] != null
                                    ? Text(_ticketData!['ticket_code'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins', color: HeronFitTheme.textPrimary, fontWeight: FontWeight.w600))
                                    : const Text('N/A'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildDetailRow(
                        context,
                        icon: SolarIconsOutline.clockCircle,
                        label: 'Booked on',
                        value: DateFormat('MMM d, yyyy, h:mm a').format(toManilaTime(widget.booking.bookingTime)),
                      ),
                      if (widget.booking.status != booking_status.BookingStatus.confirmed)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(SolarIconsOutline.infoCircle, color: statusColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontFamily: 'Poppins',
                                            color: HeronFitTheme.textSecondary,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatStatus(widget.booking.status.name),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontFamily: 'Poppins',
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
            ],
          ),
        ),
      ),
      // Floating action buttons for actions
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.booking.status == booking_status.BookingStatus.pending_receipt_number)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.receipt_long, size: 20),
                  label: const Text('Confirm Receipt Number'),
                  onPressed: () {
                    // Navigate to Activate Gym Pass screen, passing booking/session info
                    context.pushNamed(
                      AppRoutes.activateGymPassName,
                      extra: {
                        'sessionId': widget.booking.sessionId,
                        'selectedDay': widget.booking.sessionDate.toIso8601String(),
                        'bookingId': widget.booking.id,
                        'noTicketMode': false,
                        'showTestModeCheckbox': false, // Hide test mode checkbox
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
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
            if (widget.booking.status == booking_status.BookingStatus.pending_receipt_number && _isCancellable())
              const SizedBox(height: 12),
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
                    backgroundColor: Theme.of(context).colorScheme.error,
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
            if ((_isCancellable() || widget.booking.status == booking_status.BookingStatus.pending_receipt_number))
              const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(SolarIconsOutline.calendar, size: 20),
                label: const Text('Bookings'),
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
          ],
        ),
      ),
    );
  }
}
