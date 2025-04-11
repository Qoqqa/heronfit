import 'package:flutter/material.dart';
import '../../models/login_model.dart';
import '../../models/workout_model.dart';
import '../../views/auth/login_widget.dart';
import '../../views/workout/workout_widget.dart';

T createModel<T>(BuildContext context, T Function() builder) {
  return builder();
}

// Helper functions for specific models
LoginModel createLoginModel(BuildContext context, LoginWidget widget) {
  var model = LoginModel(widget);
  model.initState(context);
  return model;
}

WorkoutModel createWorkoutModel(BuildContext context, WorkoutWidget widget) {
  var model = WorkoutModel(widget);
  model.initState(context);
  return model;
}
