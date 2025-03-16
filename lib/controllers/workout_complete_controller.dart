import 'package:heronfit/models/workout_complete_model.dart';

class WorkoutCompleteController {
  final WorkoutCompleteModel model;

  WorkoutCompleteController(this.model);

  String get workoutName => model.workoutName;

  Duration get workoutDuration => model.workoutDuration;

  DateTime get startTime => model.startTime;

  DateTime get endTime => model.endTime;
}