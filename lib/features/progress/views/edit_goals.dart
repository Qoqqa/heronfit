import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/features/progress/controllers/progress_controller.dart';
import 'package:intl/intl.dart';

class EditGoalsWidget extends ConsumerStatefulWidget {
  const EditGoalsWidget({super.key});

  @override
  ConsumerState<EditGoalsWidget> createState() => _EditGoalsWidgetState();
}

class _EditGoalsWidgetState extends ConsumerState<EditGoalsWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _targetDateController = TextEditingController();

  String? _selectedGoalType;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExistingGoals();
  }

  void _loadExistingGoals() {
    final goalsAsyncValue = ref.read(userGoalsProvider);
    goalsAsyncValue.whenData((goals) {
      if (goals != null) {
        setState(() {
          _selectedGoalType = goals.goalType;
          _targetWeightController.text = goals.targetWeight?.toString() ?? '';
          _targetDateController.text =
              goals.targetDate != null
                  ? DateFormat('yyyy-MM-dd').format(goals.targetDate!)
                  : '';
        });
      }
    });
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    _targetDateController.dispose();
    super.dispose();
  }

  Future<void> _selectTargetDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(_targetDateController.text) ??
          DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _targetDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        _errorMessage = null;
      });
    }
  }

  Future<void> _submitGoals() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedGoalType == null) {
        setState(() {
          _errorMessage = 'Please select a goal type.';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final targetWeight = double.parse(_targetWeightController.text);
        final targetDate = DateFormat(
          'yyyy-MM-dd',
        ).parse(_targetDateController.text);

        await ref
            .read(progressControllerProvider.notifier)
            .updateGoals(
              goalType: _selectedGoalType!,
              targetWeight: targetWeight,
              targetDate: targetDate,
            );

        ref.invalidate(userGoalsProvider);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goals updated successfully!')),
        );
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to update goals: $e';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsyncValue = ref.watch(userGoalsProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
            onPressed: () => context.canPop() ? context.pop() : null,
          ),
          title: Text(
            'Edit Goals',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: goalsAsyncValue.when(
            data: (_) => _buildForm(context),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error loading goals: $error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Colors.black.withAlpha(25),
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.radar,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Select Your Primary Goal',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGoalType,
                        items: const [
                          DropdownMenuItem(
                            value: 'Weight Loss',
                            child: Text('Weight Loss'),
                          ),
                          DropdownMenuItem(
                            value: 'Gain Muscle',
                            child: Text('Gain Muscle'),
                          ),
                          DropdownMenuItem(
                            value: 'Improve Endurance',
                            child: Text('Improve Endurance'),
                          ),
                          DropdownMenuItem(
                            value: 'Overall Fitness',
                            child: Text('Overall Fitness'),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedGoalType = val;
                            _errorMessage = null;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Select a goal',
                          filled: true,
                          fillColor:
                              Theme.of(
                                context,
                              ).inputDecorationTheme.fillColor ??
                              Theme.of(context).scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        validator:
                            (value) =>
                                value == null
                                    ? 'Please select a goal type'
                                    : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Colors.black.withAlpha(25),
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set Your Targets (Optional)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Target Weight (kg)',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _targetWeightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., 75.5',
                          filled: true,
                          fillColor:
                              Theme.of(
                                context,
                              ).inputDecorationTheme.fillColor ??
                              Theme.of(context).scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your target weight';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Divider(
                        thickness: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Target Date',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _targetDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'YYYY-MM-DD',
                          filled: true,
                          fillColor:
                              Theme.of(
                                context,
                              ).inputDecorationTheme.fillColor ??
                              Theme.of(context).scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () => _selectTargetDate(context),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a target date';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondary.withAlpha(128),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : Text(
                          'Save Goals',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
