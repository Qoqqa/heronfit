import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/features/booking/controllers/booking_controller.dart';
import 'package:heronfit/core/theme.dart';

class ActivateGymPassScreen extends ConsumerStatefulWidget {
  const ActivateGymPassScreen({super.key});

  @override
  ConsumerState<ActivateGymPassScreen> createState() => _ActivateGymPassScreenState();
}

class _ActivateGymPassScreenState extends ConsumerState<ActivateGymPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ticketIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _ticketIdController.dispose();
    super.dispose();
  }

  Future<void> _onActivatePressed() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final fullTicketId = 'ARNO2025${_ticketIdController.text.trim()}';

      try {
        final success = await ref
            .read(bookingControllerProvider.notifier)
            .validateTicket(fullTicketId);

        if (mounted) {
          if (success) {
            context.push(AppRoutes.selectSession);
          } else {
            // Read the state of the booking controller *after* validateTicket returned false
            final bookingStateOnError = ref.read(bookingControllerProvider);
            String? actualErrorMessage;

            // Extract error message from AsyncError state
            bookingStateOnError.whenOrNull(
              error: (err, stackTrace) { // stackTrace might not be needed for display
                actualErrorMessage = err.toString();
                // Attempt to make the error message more user-friendly if it's a generic Exception string
                if (actualErrorMessage != null && actualErrorMessage!.startsWith("Exception: ")) {
                  actualErrorMessage = actualErrorMessage!.substring("Exception: ".length);
                }
              }
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(actualErrorMessage ?? 'Ticket activation failed. Please try again.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Activate Your Gym Pass', // Specific title for this screen
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: HeronFitTheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Activate Your Gym Pass',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'To book your single gym session at the University of Makati HPSB 11th Floor Gym, please enter your valid Ticket ID.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _ticketIdController,
                  keyboardType: TextInputType.number, // Set keyboard to numeric
                  maxLength: 7, // Enforce 7 digits max input
                  decoration: const InputDecoration(
                    labelText: 'Ticket Number (7 Digits)', // Updated label
                    hintText: 'XXXXXXX', // Updated hint text
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                    counterText: "", // Hide the default counter text from maxLength
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your 7-digit ticket number';
                    }
                    // Validation for exactly 7 digits
                    final regex = RegExp(r'^\d{7}$');
                    if (!regex.hasMatch(value.trim())) {
                      return 'Enter a valid 7-digit ticket number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _onActivatePressed,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Activate & Find Sessions'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
