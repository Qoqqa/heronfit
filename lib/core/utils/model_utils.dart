import 'package:flutter/material.dart';

import '../../features/auth/views/login_widget.dart';
import '../../features/auth/models/login_model.dart';
import '../../features/workout/models/workout_model.dart';
import '../../features/workout/views/workout_screen.dart';

T createModel<T>(BuildContext context, T Function() builder) {
  return builder();
}

// Helper functions for specific models
LoginModel createLoginModel(BuildContext context, LoginWidget widget) {
  var model = LoginModel(widget);
  model.initState(context);
  return model;
}

// WorkoutModel createWorkoutModel(BuildContext context, WorkoutWidget widget) {
//   var model = WorkoutModel();
//   return model;
// }
