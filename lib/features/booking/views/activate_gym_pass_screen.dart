import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';
import '../providers/activate_gym_pass_providers.dart';
import '../models/user_ticket_model.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';

class ActivateGymPassScreen extends ConsumerStatefulWidget {
  const ActivateGymPassScreen({super.key});

  @override
  ConsumerState<ActivateGymPassScreen> createState() =>
      _ActivateGymPassScreenState();
}

class _ActivateGymPassScreenState extends ConsumerState<ActivateGymPassScreen> {
  final TextEditingController _ticketCodeController = TextEditingController();
  bool _noTicketMode = false;

  @override
  void dispose() {
    _ticketCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activateState = ref.watch(activateGymPassStateProvider);
    final activateNotifier = ref.read(activateGymPassStateProvider.notifier);

    ref.listen<AsyncValue<UserTicket?>>(activateGymPassStateProvider, (
      previous,
      next,
    ) {
      // Ensure we only react to successful data states and not on rebuilds
      // Also, ensure we are not in _noTicketMode, as navigation is handled differently then
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
            // Pass the validated ticket to the next screen
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
            // Only revert if not in noTicketMode and a ticket might have been processed
            if (!_noTicketMode &&
                ref.read(activateGymPassStateProvider).value?.status ==
                    TicketStatus.pending_booking) {
              try {
                await activateNotifier.revertTicketToActive();
              } catch (e) {
                // Optionally show a snackbar or dialog if reverting fails critically
              }
            }
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Activate Gym Pass', // Updated title
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Adjusted vertical padding
        // Removed Center widget to allow left alignment
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Changed to start
            crossAxisAlignment: CrossAxisAlignment.start, // Changed to start
            children: [
              Icon(SolarIconsBold.ticket, size: 48, color: Theme.of(context).colorScheme.primary), // Adjusted size
              const SizedBox(height: 20), // Adjusted spacing
              Text(
                'Enter Your Gym Pass ID',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                textAlign: TextAlign.start, // Explicitly set to start
              ),
              const SizedBox(height: 10), // Adjusted spacing
              Text(
                'Please enter your 7-digit Ticket ID to book your session at the UMak HPSB 11th Floor Gym.',
                textAlign: TextAlign.start, // Explicitly set to start
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 28), // Adjusted spacing
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
                contentPadding: EdgeInsets.zero, // Adjust padding for CheckboxListTile if needed
              ),
              const SizedBox(height: 20), // Adjusted spacing
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
                  textAlign: TextAlign.start, // Changed to start
                  keyboardType: TextInputType.text,
                  maxLength: 7,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                ),
              if (!_noTicketMode) const SizedBox(height: 28), // Adjusted spacing
              activateState.isLoading
                  ? const Center(child: CircularProgressIndicator()) // Keep CircularProgressIndicator centered
                  : SizedBox( // Wrap button in SizedBox to control width if CrossAxisAlignment.start shrinks it
                      width: double.infinity, // Make button take full width
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith( // Updated text style
                                fontWeight: FontWeight.bold,
                                // color: Theme.of(context).colorScheme.onPrimary, // Already set by foregroundColor
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
