import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/activate_gym_pass_providers.dart';
import '../models/user_ticket_model.dart';
import 'package:go_router/go_router.dart';

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
            print(
              "SUCCESS: Navigate to SelectSessionScreen with ticket: ${ticket.toJson()}",
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
        title: const Text('Activate Your Gym Pass'),
        leading: BackButton(
          onPressed: () async {
            // Only revert if not in noTicketMode and a ticket might have been processed
            if (!_noTicketMode &&
                ref.read(activateGymPassStateProvider).value?.status ==
                    TicketStatus.pending_booking) {
              await activateNotifier.revertTicketToActive();
            }
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Activate Your Gym Pass',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'To book your single gym session at the University of Makati HPSB 11th Floor Gym, please enter your valid Ticket ID.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                CheckboxListTile(
                  title: const Text("Proceed without Ticket ID (for testing)"),
                  value: _noTicketMode,
                  onChanged: (bool? value) {
                    setState(() {
                      _noTicketMode = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),
                if (!_noTicketMode)
                  TextField(
                    controller: _ticketCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Ticket ID',
                      hintText: 'e.g., XXXXXXX or XXXX-XXXX-XXXX-XXXX',
                      border: OutlineInputBorder(),
                      helperText:
                          'Find your Ticket ID on your purchase confirmation email or receipt.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (!_noTicketMode) const SizedBox(height: 24),
                activateState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (_noTicketMode) {
                          print("Proceeding without ticket (test mode).");
                          // Navigate directly, potentially passing a flag
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
                      child: Text(
                        _noTicketMode
                            ? 'Proceed & Find Sessions'
                            : 'Activate & Find Sessions',
                      ),
                    ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
