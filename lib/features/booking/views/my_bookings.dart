import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final myBookingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    throw Exception('User not authenticated');
  }

  final email = user.email;
  if (email == null) {
    throw Exception('User email is null');
  }

  final response = await Supabase.instance.client
      .from('sessions')
      .select()
      .eq('email', email) // Ensure email is non-null
      .order('date', ascending: true)
      .order('time', ascending: true);

  if (response == null || response.isEmpty) {
    return [];
  }

  return List<Map<String, dynamic>>.from(response);
});

class MyBookingsWidget extends ConsumerWidget {
  const MyBookingsWidget({super.key});

  static String routePath = '/myBookings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsyncValue = ref.watch(myBookingsProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: HeronFitTheme.bgLight,
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
            'My Bookings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: bookingsAsyncValue.when(
            data: (bookings) {
              if (bookings.isEmpty) {
                return const Center(
                  child: Text(
                    'No bookings found.',
                    style: TextStyle(
                      fontSize: 16,
                      color: HeronFitTheme.textMuted,
                    ),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              // Handle booking tap
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: HeronFitTheme.bgSecondary,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 40,
                                    color: HeronFitTheme.textMuted.withOpacity(0.1),
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              color: HeronFitTheme.primary,
                                              size: 32,
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Gym Session',
                                                  style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  'Ticket ID: ${booking['ticket_id']}',
                                                  style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                                Text(
                                                  'Date: ${DateFormat('MMMM d, yyyy').format(DateTime.parse(booking['date']))}',
                                                  style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                                                    fontSize: 10,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                                Text(
                                                  'Time: ${booking['time']}',
                                                  style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                                                    fontSize: 10,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/home'); // Navigate back to home
                    },
                    icon: const Icon(Icons.home, size: 15),
                    label: const Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HeronFitTheme.primaryDark,
                      foregroundColor: HeronFitTheme.bgLight,
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: HeronFitTheme.textTheme.titleSmall?.copyWith(
                        color: HeronFitTheme.bgLight,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Center(
              child: Text(
                'Error: ${error.toString()}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}