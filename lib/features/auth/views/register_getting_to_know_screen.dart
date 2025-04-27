import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:intl/intl.dart';
import '../controllers/registration_controller.dart';
// TODO: import SolarIcons when available

class RegisterGettingToKnowScreen extends ConsumerStatefulWidget {
  const RegisterGettingToKnowScreen({super.key});

  @override
  ConsumerState<RegisterGettingToKnowScreen> createState() =>
      _RegisterGettingToKnowScreenState();
}

class _RegisterGettingToKnowScreenState
    extends ConsumerState<RegisterGettingToKnowScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _birthdayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final birthday = ref.read(registrationProvider).birthday;
    if (birthday.isNotEmpty) {
      try {
        // Attempt to parse and format the stored date
        final parsedDate = DateTime.parse(birthday);
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        // Handle potential parsing errors if the stored string is invalid
        print("Error parsing stored birthday: $e");
        _birthdayController.text = '';
      }
    }
  }

  @override
  void dispose() {
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // Default to 18 years ago
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: HeronFitTheme.primary, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: HeronFitTheme.textPrimary, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: HeronFitTheme.primaryDark, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _birthdayController.text = formattedDate;
      ref
          .read(registrationProvider.notifier)
          .updateBirthday(picked.toIso8601String());
    }
  }

  @override
  Widget build(BuildContext context) {
    final registration = ref.watch(registrationProvider);
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
          child: Form(
            key: _formKey,
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
                              Icons.person_outline, // Placeholder
                              color: HeronFitTheme.primary,
                              size: 80,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Tell us a little about yourself',
                          style: HeronFitTheme.textTheme.headlineSmall
                              ?.copyWith(
                                color: HeronFitTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This will help us create a personalized experience just for you.',
                          style: HeronFitTheme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        DropdownButtonFormField<String>(
                          value:
                              registration.gender.isEmpty
                                  ? null
                                  : registration.gender,
                          decoration: InputDecoration(
                            labelText: 'Choose Gender',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: HeronFitTheme.bgSecondary,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Other'),
                            ),
                            DropdownMenuItem(
                              value: 'prefer_not_to_say',
                              child: Text('Prefer not to say'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              registrationNotifier.updateGender(value);
                            }
                          },
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please select a gender'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _birthdayController,
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: HeronFitTheme.bgSecondary,
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: HeronFitTheme.textMuted,
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your date of birth'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: registration.weight,
                                onChanged: registrationNotifier.updateWeight,
                                decoration: InputDecoration(
                                  labelText: 'Your Weight',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: HeronFitTheme.bgSecondary,
                                  suffixText: 'KG',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Enter weight';
                                  if (double.tryParse(value) == null)
                                    return 'Invalid number';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                initialValue: registration.height,
                                onChanged: registrationNotifier.updateHeight,
                                decoration: InputDecoration(
                                  labelText: 'Your Height',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: HeronFitTheme.bgSecondary,
                                  suffixText: 'CM',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Enter height';
                                  if (int.tryParse(value) == null)
                                    return 'Invalid number';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.pushNamed(AppRoutes.registerSetGoals);
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
                    'Next',
                    style: HeronFitTheme.textTheme.titleSmall?.copyWith(
                      color: HeronFitTheme.bgLight,
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
