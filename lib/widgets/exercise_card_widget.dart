import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:solar_icons/solar_icons.dart'; // Import icons
import 'package:heronfit/features/workout/widgets/rest_timer_dialog.dart'; // Corrected import path for the dialog

// Define callback types
typedef UpdateSetDataCallback =
    void Function(
      int setIndex, {
      int? kg,
      int? reps,
      bool? completed,
      Duration? restTimerDuration,
    });
typedef RemoveSetCallback = void Function(int setIndex);

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final String? workoutId;
  final VoidCallback onAddSet;
  final UpdateSetDataCallback onUpdateSetData; // Callback for updating set data
  final RemoveSetCallback onRemoveSet; // Callback for removing a set

  const ExerciseCard({
    Key? key,
    required this.exercise,
    required this.workoutId,
    required this.onAddSet,
    required this.onUpdateSetData, // Require callback
    required this.onRemoveSet, // Require callback
  }) : super(key: key);

  @override
  _ExerciseCardState createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _isResting = false; // Track if rest timer is active for this exercise

  @override
  void dispose() {
    super.dispose();
  }

  void _showRestTimer(int setIndex, Duration duration) {
    setState(() {
      _isResting = true; // Disable Add Set button
    });
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return RestTimerDialog(
          initialDuration: duration,
          onSkip: () {
            // Timer skipped
            if (mounted) {
              setState(() {
                _isResting = false; // Re-enable Add Set button
              });
            }
          },
          onTimerEnd: () {
            // Timer finished normally
            if (mounted) {
              setState(() {
                _isResting = false; // Re-enable Add Set button
              });
            }
          },
          onAdjustDuration: (newDuration) {
            // Update the default duration for this specific set in the main state
            widget.onUpdateSetData(setIndex, restTimerDuration: newDuration);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 40.0,
            color: Colors.grey.withOpacity(0.3),
            offset: const Offset(0.0, 10.0),
          ),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.exercise.name,
                    textAlign: TextAlign.start,
                    style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                      color: HeronFitTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'SET',
                  style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'KG',
                  style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'REPS',
                  style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                VerticalDivider(color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 8.0),
            ListView.separated(
              padding: EdgeInsets.zero,
              primary: false,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: widget.exercise.sets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8.0),
              itemBuilder: (context, setsListIndex) {
                final set = widget.exercise.sets[setsListIndex];
                final kgController = TextEditingController(
                  text: set.kg > 0 ? set.kg.toString() : '',
                );
                final repsController = TextEditingController(
                  text: set.reps > 0 ? set.reps.toString() : '',
                );
                kgController.selection = TextSelection.fromPosition(
                  TextPosition(offset: kgController.text.length),
                );
                repsController.selection = TextSelection.fromPosition(
                  TextPosition(offset: repsController.text.length),
                );

                return Dismissible(
                  key: ValueKey('${widget.exercise.id}_set_$setsListIndex'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    widget.onRemoveSet(setsListIndex);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Set ${setsListIndex + 1} removed'),
                      ),
                    );
                  },
                  background: Container(
                    color: HeronFitTheme.error.withOpacity(0.8),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(
                      SolarIconsOutline.trashBinMinimalistic,
                      color: Colors.white,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${setsListIndex + 1}',
                          textAlign: TextAlign.center,
                          style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                            color: HeronFitTheme.textMuted,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          controller: kgController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'KG',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            widget.onUpdateSetData(
                              setsListIndex,
                              kg: int.tryParse(value) ?? 0,
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          controller: repsController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Reps',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            widget.onUpdateSetData(
                              setsListIndex,
                              reps: int.tryParse(value) ?? 0,
                            );
                          },
                        ),
                      ),
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: set.completed,
                          visualDensity: VisualDensity.compact,
                          onChanged: (bool? value) {
                            if (value != null) {
                              widget.onUpdateSetData(
                                setsListIndex,
                                completed: value,
                              );
                              if (value && !_isResting) {
                                _showRestTimer(
                                  setsListIndex,
                                  set.restTimerDuration,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed:
                  _isResting
                      ? null
                      : () {
                        widget.onAddSet();
                      },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40.0),
                backgroundColor:
                    _isResting ? Colors.grey : HeronFitTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                _isResting ? 'Resting...' : 'Add Set',
                style: HeronFitTheme.textTheme.labelMedium?.copyWith(
                  color: HeronFitTheme.bgLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
