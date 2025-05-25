import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme/theme.dart';
import 'package:heronfit/features/booking/controllers/booking_controller.dart';

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(bookingControllerProvider.notifier)
          .validateTicket(_ticketIdController.text.trim());

      if (!mounted) return;

      if (success) {
        // Navigate to session selection screen
        // We'll implement this navigation in the next step
        if (mounted) {
          Navigator.pushNamed(context, '/select-session');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Session'),
      ),
      body: SingleChildScrollView(
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
                decoration: const InputDecoration(
                  labelText: 'Ticket ID',
                  hintText: 'XXXX-XXXX-XXXX-XXXX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Ticket ID';
                  }
                  // Basic format validation (can be enhanced)
                  final regex = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
                  if (!regex.hasMatch(value)) {
                    return 'Please enter a valid Ticket ID format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Find your Ticket ID on your purchase confirmation email or receipt.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
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
    );
  }
}
