import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final Exercise exercise;

  ExerciseDetailsScreen({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.network(exercise.gifUrl, width: 200, height: 200)),
            SizedBox(height: 16),
            Text("Target Muscles: ${exercise.targetMuscles.join(', ')}", style: TextStyle(fontSize: 18)),
            Text("Body Parts: ${exercise.bodyParts.join(', ')}", style: TextStyle(fontSize: 18)),
            Text("Equipments: ${exercise.equipments.join(', ')}", style: TextStyle(fontSize: 18)),
            Text("Secondary Muscles: ${exercise.secondaryMuscles.join(', ')}", style: TextStyle(fontSize: 18)),
            Text("Instructions: ${exercise.instructions.join(', ')}", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
