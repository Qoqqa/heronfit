import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart';
import '../providers/activate_gym_pass_providers.dart';
import '../models/user_ticket_model.dart';
import '../models/session_model.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/features/booking/providers/booking_providers.dart';
import 'package:heronfit/features/booking/models/booking_model.dart';
import 'package:heronfit/features/booking/services/booking_supabase_service.dart';

class ActivateGymPassScreen extends ConsumerStatefulWidget {
  final Object? extra;
  const ActivateGymPassScreen({Key? key, this.extra}) : super(key: key);

  @override
  ConsumerState<ActivateGymPassScreen> createState() =>
      _ActivateGymPassScreenState();
}

class _ActivateGymPassScreenState extends ConsumerState<ActivateGymPassScreen> {
  final TextEditingController _ticketCodeController = TextEditingController();
  bool _noTicketMode = false;
  bool _isLoadingCheck = true;
  Session? _session;
  DateTime? _selectedDay;
  bool _isLoadingSession = true;

  @override
  void initState() {
    super.initState();
    _loadSessionAndDate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveBooking();
    });
  }

  Future<void> _loadSessionAndDate() async {
    final extra = widget.extra;
    String? sessionId;
    String? selectedDayStr;
    if (extra is Map) {
      sessionId = extra['sessionId'] as String?;
      selectedDayStr = extra['selectedDay'] as String?;
      _noTicketMode = extra['noTicketMode'] as bool? ?? false;
    }
    debugPrint(
      '[ActivateGymPassScreen] _loadSessionAndDate: sessionId=$sessionId, selectedDayStr=$selectedDayStr, noTicketMode=$_noTicketMode',
    );
    if (sessionId == null || selectedDayStr == null) {
      debugPrint(
        '[ActivateGymPassScreen] ERROR: sessionId or selectedDayStr is null!',
      );
      setState(() {
        _isLoadingSession = false;
      });
      return;
    }
    try {
      final bookingService = ref.read(bookingSupabaseServiceProvider);
      final sessionList = await bookingService.getSessionsForDate(
        DateTime.parse(selectedDayStr),
      );
      _session = sessionList.firstWhere(
        (s) => s.id == sessionId,
        orElse: () => throw Exception('Session not found'),
      );
      _selectedDay = DateTime.parse(selectedDayStr);
      debugPrint(
        '[ActivateGymPassScreen] Loaded session: $_session, selectedDay: $_selectedDay',
      );
    } catch (e) {
      debugPrint('[ActivateGymPassScreen] ERROR loading session: $e');
    }
    setState(() {
      _isLoadingSession = false;
    });
  }

  Future<void> _checkActiveBooking() async {
    setState(() {
      _isLoadingCheck = true;
    });
    try {
      debugPrint(
        '[ActivateGymPassScreen] _checkActiveBooking: Checking for active bookings...',
      );
      final activeBooking = await ref.read(activeBookingCheckProvider.future);
      debugPrint(
        '[ActivateGymPassScreen] _checkActiveBooking: activeBooking=$activeBooking',
      );
      if (mounted && activeBooking != null) {
        _showActiveBookingDialog(activeBooking);
      } else {
        setState(() {
          _isLoadingCheck = false;
        });
      }
    } catch (e, stack) {
      debugPrint(
        '[ActivateGymPassScreen] _checkActiveBooking: ERROR: $e\n$stack',
      );
      if (mounted) {
        setState(() {
          _isLoadingCheck = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error checking booking status: [31m${e.toString()}[0m',
            ),
            backgroundColor: Colors.red,
          ),
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
            'You already have an active booking for ${activeBooking.sessionCategory} on ${DateFormat('MMM d, yyyy').format(activeBooking.sessionDate)} at ${activeBooking.sessionTimeRangeShort}.\n\nPlease cancel your current booking or wait for it to complete before booking another session.',
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
              child: const Text('View Booking Details'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push(AppRoutes.bookingDetails, extra: activeBooking.toJson());
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
    if (_isLoadingCheck || _isLoadingSession) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading session details...'),
            ],
          ),
        ),
      );
    }
    if (_session == null || _selectedDay == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Session or date not found.')),
      );
    }

    final activateState = ref.watch(activateGymPassStateProvider);
    final activateNotifier = ref.read(activateGymPassStateProvider.notifier);

    ref.listen<AsyncValue<UserTicket?>>(activateGymPassStateProvider, (
      previous,
      next,
    ) {
      debugPrint(
        '[ActivateGymPassScreen] ref.listen: next=$next, _noTicketMode=$_noTicketMode, _session=$_session, _selectedDay=$_selectedDay',
      );
      if (!_noTicketMode && next is AsyncData && next.value != null) {
        final ticket = next.value!;
        debugPrint(
          '[ActivateGymPassScreen] ref.listen: Ticket validated, navigating to review booking. ticket=$ticket',
        );
        if (ticket.status == TicketStatus.pending_booking &&
            _session != null &&
            _selectedDay != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Ticket ${ticket.ticketCode} validated. Proceed to review booking.',
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.pushNamed(
              AppRoutes.reviewBooking,
              extra: {
                'session': _session!,
                'selectedDay': _selectedDay!,
                'activatedTicket': ticket,
                'noTicketMode': false,
              },
            );
          }
        } else {
          debugPrint(
            '[ActivateGymPassScreen] ref.listen: Ticket not valid or session/selectedDay missing.',
          );
        }
      } else if (next is AsyncError) {
        debugPrint('[ActivateGymPassScreen] ref.listen: Error: ${next.error}');
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
              Icon(
                SolarIconsBold.ticket,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Enter Your Receipt Number',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 10),
              Text(
                'Please enter your 7-digit Receipt Number to book your session at the UMak HPSB 11th Floor Gym.',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              CheckboxListTile(
                title: Text(
                  "Proceed without Receipt Number (Test Mode)",
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
              TextFormField(
                controller: _ticketCodeController,
                enabled: !_noTicketMode,
                decoration: InputDecoration(
                  hintText: 'Enter your 7-digit Receipt Number',
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
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null,
              ),
              const SizedBox(height: 28),
              activateState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        debugPrint(
                          '[ActivateGymPassScreen] Button pressed. _noTicketMode=$_noTicketMode, _session=$_session, _selectedDay=$_selectedDay',
                        );
                        if (_noTicketMode) {
                          if (_session != null && _selectedDay != null) {
                            debugPrint(
                              '[ActivateGymPassScreen] Test mode: Navigating to review booking with session=$_session, selectedDay=$_selectedDay',
                            );
                            context.goNamed(
                              AppRoutes.reviewBooking,
                              extra: {
                                'session': _session!,
                                'selectedDay': _selectedDay!,
                                'activatedTicket': null,
                                'noTicketMode': true,
                              },
                            );
                          } else {
                            debugPrint(
                              '[ActivateGymPassScreen] Test mode: _session or _selectedDay is null, cannot navigate.',
                            );
                          }
                        } else {
                          final ticketCode = _ticketCodeController.text.trim();
                          debugPrint(
                            '[ActivateGymPassScreen] Normal mode: ticketCode="$ticketCode"',
                          );
                          if (ticketCode.isNotEmpty) {
                            debugPrint(
                              '[ActivateGymPassScreen] Normal mode: activating and finding sessions.',
                            );
                            activateNotifier.activateAndFindSessions(
                              ticketCode,
                            );
                          } else {
                            debugPrint(
                              '[ActivateGymPassScreen] Normal mode: ticketCode is empty, showing snackbar.',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a Receipt Number.'),
                                backgroundColor: Colors.orangeAccent,
                              ),
                            );
                          }
                        }
                      },
                      icon: Icon(SolarIconsOutline.arrowRight, size: 20),
                      label: const Text('Verify & Continue'),
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
