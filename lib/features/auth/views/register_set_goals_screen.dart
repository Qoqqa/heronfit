import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/widgets/loading_indicator.dart';
import '../controllers/registration_controller.dart';
// TODO: import SolarIcons when available

class RegisterSetGoalsScreen extends ConsumerStatefulWidget {
  const RegisterSetGoalsScreen({super.key});

  @override
  ConsumerState<RegisterSetGoalsScreen> createState() =>
      _RegisterSetGoalsScreenState();
}

class _RegisterSetGoalsScreenState
    extends ConsumerState<RegisterSetGoalsScreen> {
  bool _isLoading = false;
  String? _selectedGoal;

  @override
  void initState() {
    super.initState();
    // Initialize local state from provider if needed
    _selectedGoal = ref.read(registrationProvider).goal;
  }

  @override
  Widget build(BuildContext context) {
    final registrationNotifier = ref.read(registrationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeronFitTheme.bgLight,
        elevation: 0,
        leading: BackButton(color: HeronFitTheme.primary),
      ),
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: HeronFitTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.flag_outlined, // Placeholder
                            color: HeronFitTheme.primary,
                            size: 80,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Let's Conquer Your Fitness Goals",
                        style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                          color: HeronFitTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tell us what you\'re aiming for, and we\'ll guide you to success.',
                        style: HeronFitTheme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      DropdownButtonFormField<String>(
                        value:
                            _selectedGoal?.isEmpty ?? true
                                ? null
                                : _selectedGoal,
                        decoration: InputDecoration(
                          labelText: 'Select Your Goal',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: HeronFitTheme.bgSecondary,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'lose_weight',
                            child: Text('Lose Weight and Feel Confident'),
                          ),
                          DropdownMenuItem(
                            value: 'build_muscle',
                            child: Text('Build Muscle and Strength'),
                          ),
                          DropdownMenuItem(
                            value: 'improve_endurance',
                            child: Text('Improve Endurance'),
                          ),
                          DropdownMenuItem(
                            value: 'general_fitness',
                            child: Text('General Fitness'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedGoal = value;
                            });
                            registrationNotifier.updateGoal(value);
                          }
                        },
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please select a goal'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: LoadingIndicator(),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedGoal == null || _selectedGoal!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a goal first.'),
                        ),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);
                    try {
                      // Call initiateSignUp BEFORE navigating
                      await registrationNotifier.initiateSignUp();
                      // If successful, navigate to verification
                      if (mounted) {
                        context.pushNamed(AppRoutes.registerVerify);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
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
                  child: Text(
                    'Confirm & Verify Email',
                    style: HeronFitTheme.textTheme.titleSmall?.copyWith(
                      color: HeronFitTheme.bgLight,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
