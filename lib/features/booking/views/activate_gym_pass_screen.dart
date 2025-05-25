import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/activate_gym_pass_providers.dart';
import '../models/user_ticket_model.dart';
import 'package:go_router/go_router.dart';

class ActivateGymPassScreen extends ConsumerWidget {
  final TextEditingController _ticketCodeController = TextEditingController();

  ActivateGymPassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activateState = ref.watch(activateGymPassStateProvider);

    ref.listen<AsyncValue<UserTicket?>>(activateGymPassStateProvider, (
      _,
      next,
    ) {
      next.whenOrNull(
        data: (ticket) {
          if (ticket != null && ticket.status == TicketStatus.pending_booking) {
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
            GoRouter.of(context).push('/booking/select-session', extra: ticket);
          }
        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activate Your Gym Pass'),
        leading: BackButton(
          onPressed: () {
            ref
                .read(activateGymPassStateProvider.notifier)
                .revertTicketToActive();
            Navigator.of(context).pop();
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
                TextField(
                  controller: _ticketCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Ticket ID',
                    hintText: 'e.g., XXXX-XXXX-XXXX-XXXX',
                    border: OutlineInputBorder(),
                    helperText:
                        'Find your Ticket ID on your purchase confirmation email or receipt.',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                activateState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        final ticketCode = _ticketCodeController.text.trim();
                        if (ticketCode.isNotEmpty) {
                          FocusScope.of(context).unfocus();
                          ref
                              .read(activateGymPassStateProvider.notifier)
                              .activateAndFindSessions(ticketCode);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a Ticket ID.'),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          );
                        }
                      },
                      child: const Text('Activate & Find Sessions'),
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
