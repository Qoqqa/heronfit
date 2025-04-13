import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:heronfit/features/workout/models/set_data_model.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final String? workoutId;
  final VoidCallback onAddSet;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    required this.workoutId,
    required this.onAddSet,
  }) : super(key: key);

  @override
  _ExerciseCardState createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
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
                    widget.exercise.name ?? '[Exercise Name]',
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
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('${setsListIndex + 1}'), // Display set number
                    SizedBox(
                      width: 50,
                      child: TextFormField(
                        decoration: const InputDecoration(hintText: 'KG'),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          set.kg = int.tryParse(value) ?? 0;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextFormField(
                        decoration: const InputDecoration(hintText: 'Reps'),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          set.reps = int.tryParse(value) ?? 0;
                        },
                      ),
                    ),
                    Checkbox(
                      value: set.completed,
                      onChanged: (bool? value) {
                        setState(() {
                          set.completed = value ?? false;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(
              height: 16.0,
            ), // Improved spacing between set items and button
            ElevatedButton(
              onPressed: () {
                widget.onAddSet();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  40.0,
                ), // Increased padding
                backgroundColor: HeronFitTheme.primary,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                ), // Increased padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Add Set',
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
