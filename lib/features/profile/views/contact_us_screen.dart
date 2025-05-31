import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import flutter_riverpod
import '../../../core/theme.dart';
import '../controllers/feedback_controller.dart'; // Import the new controller

class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({super.key});

  static String routeName = 'ContactUs';
  static String routePath = '/contactUs';

  @override
  ConsumerState<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedbackState = ref.watch(feedbackControllerProvider);

    ref.listen<FeedbackState>(feedbackControllerProvider, (previous, next) {
      if (next.status == FeedbackStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback sent successfully!'),
            backgroundColor: HeronFitTheme.success,
          ),
        );
        _feedbackController.clear();
        ref.read(feedbackControllerProvider.notifier).resetState();
      } else if (next.status == FeedbackStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'An unexpected error occurred.'),
            backgroundColor: HeronFitTheme.error,
          ),
        );
        ref.read(feedbackControllerProvider.notifier).resetState();
      }
    });

    return SafeArea(
      child: Scaffold(
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
            'Contact Us',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Get In Touch Section
                Text(
                  'Get In Touch',
                  style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                    color: HeronFitTheme.primary,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'re happy to hear from you! Here are a few ways to reach our support team:',
                  style: HeronFitTheme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: HeronFitTheme.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Email: heronfit@gmail.com',
                      style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      color: HeronFitTheme.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Phone: 09123456789',
                      style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Share Your Feedback Section
                Text(
                  'Share Your Feedback',
                  style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                    color: HeronFitTheme.primary,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your experience is important to us. Please let us know your thoughts on HeronFit.\n\n'
                  '1. Was there something we could have done better?\n'
                  '2. What did you enjoy about your experience?\n'
                  '3. Do you have any suggestions for improvement?\n\n'
                  'We value your feedback and use it to make HeronFit even better.\n\n'
                  'Thank you for choosing HeronFit!',
                  style: HeronFitTheme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Leave A Feedback Section
                Text(
                  'Leave A Feedback',
                  style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                    color: HeronFitTheme.primary,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(height: 8),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _feedbackController,
                    autofocus: false,
                    obscureText: false,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText:
                          'Describe in detail what you want to let us know here...',
                      hintStyle: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                        color: HeronFitTheme.textMuted,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: HeronFitTheme.primary,
                          width: 2,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: HeronFitTheme.primaryDark,
                          width: 2,
                        ),
                      ),
                    ),
                    style: HeronFitTheme.textTheme.bodyMedium,
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your feedback.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Send Feedback Button
                ElevatedButton(
                  onPressed:
                      feedbackState.status == FeedbackStatus.loading
                          ? null
                          : () {
                            if (_formKey.currentState!.validate()) {
                              ref
                                  .read(feedbackControllerProvider.notifier)
                                  .sendFeedback(_feedbackController.text);
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeronFitTheme.primaryDark,
                    foregroundColor: HeronFitTheme.bgLight,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      feedbackState.status == FeedbackStatus.loading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            'Send Feedback',
                            style: HeronFitTheme.textTheme.titleSmall?.copyWith(
                              color: HeronFitTheme.bgLight,
                              letterSpacing: 0.0,
                            ),
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
