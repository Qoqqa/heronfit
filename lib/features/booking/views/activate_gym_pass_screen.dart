import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart';
import '../providers/activate_gym_pass_providers.dart';
import '../models/user_ticket_model.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/features/booking/providers/booking_providers.dart';
import 'package:heronfit/features/booking/models/booking_model.dart';

class ActivateGymPassScreen extends ConsumerStatefulWidget {
  const ActivateGymPassScreen({super.key});

  @override
  ConsumerState<ActivateGymPassScreen> createState() =>
      _ActivateGymPassScreenState();
}

class _ActivateGymPassScreenState extends ConsumerState<ActivateGymPassScreen> {
  final TextEditingController _ticketCodeController = TextEditingController();
  bool _noTicketMode = false;
  bool _isLoadingCheck = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveBooking();
    });
  }

  Future<void> _checkActiveBooking() async {
    setState(() {
      _isLoadingCheck = true;
    });
    try {
      final activeBooking = await ref.read(activeBookingCheckProvider.future);
      if (mounted && activeBooking != null) {
        _showActiveBookingDialog(activeBooking);
      } else {
        setState(() {
          _isLoadingCheck = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCheck = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not verify active bookings: ${e.toString()}')),
        );
      }
    }
  }

  void _showActiveBookingDialog(Booking activeBooking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Active Booking Found'),
          content: Text(
            'You already have an active booking for ${activeBooking.sessionCategory} on ${DateFormat('MMM d, yyyy').format(activeBooking.sessionDate)} at ${activeBooking.sessionTimeRangeShort}.\n\nWould you like to view it or go home?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Go Home'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go(AppRoutes.home);
              },
            ),
            FilledButton(
              child: const Text('View My Booking'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push(AppRoutes.bookingDetails, extra: activeBooking);
              },
            ),
          ],
        );
      },
    ).then((_) {
      if (mounted && ref.read(activeBookingCheckProvider).valueOrNull != null) {
        if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
        } else {
          context.go(AppRoutes.home);
        }
      }
    });
  }

  @override
  void dispose() {
    _ticketCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCheck) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking for active bookings...'),
            ],
          ),
        ),
      );
    }

    final activateState = ref.watch(activateGymPassStateProvider);
    final activateNotifier = ref.read(activateGymPassStateProvider.notifier);

    ref.listen<AsyncValue<UserTicket?>>(activateGymPassStateProvider, (
      previous,
      next,
    ) {
      if (!_noTicketMode && next is AsyncData && next.value != null) {
        final ticket = next.value!;
        if (ticket.status == TicketStatus.pending_booking) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Ticket ${ticket.ticketCode} validated. Proceed to select a session.',
                ),
                backgroundColor: Colors.green,
              ),
            );
            GoRouter.of(context).push('/booking/select-session', extra: ticket);
          }
        }
      } else if (next is AsyncError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
          onPressed: () async {
            if (!_noTicketMode &&
                ref.read(activateGymPassStateProvider).value?.status ==
                    TicketStatus.pending_booking) {
              try {
                await activateNotifier.revertTicketToActive();
              } catch (e) {}
            }
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Activate Gym Pass',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(SolarIconsBold.ticket, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                'Enter Your Gym Pass ID',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 10),
              Text(
                'Please enter your 7-digit Ticket ID to book your session at the UMak HPSB 11th Floor Gym.',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 28),
              CheckboxListTile(
                title: Text(
                  "Proceed without Ticket ID (Test Mode)",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                value: _noTicketMode,
                onChanged: (bool? value) {
                  setState(() {
                    _noTicketMode = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Theme.of(context).colorScheme.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              if (!_noTicketMode)
                TextFormField(
                  controller: _ticketCodeController,
                  decoration: InputDecoration(
                    hintText: 'Enter your 7-digit Ticket ID',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(
                        SolarIconsOutline.ticket,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.text,
                  maxLength: 7,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                ),
              if (!_noTicketMode) const SizedBox(height: 28),
              activateState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (_noTicketMode) {
                            GoRouter.of(context).push(
                              '/booking/select-session',
                              extra: {'noTicketMode': true},
                            );
                          } else {
                            final ticketCode = _ticketCodeController.text.trim();
                            if (ticketCode.isNotEmpty) {
                              activateNotifier.activateAndFindSessions(
                                ticketCode,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a Ticket ID.'),
                                  backgroundColor: Colors.orangeAccent,
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(
                          _noTicketMode ? SolarIconsOutline.doubleAltArrowRight : SolarIconsOutline.arrowRight,
                          size: 20,
                        ),
                        label: Text(
                          _noTicketMode
                              ? 'Skip & Find Sessions'
                              : 'Verify & Continue',
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
