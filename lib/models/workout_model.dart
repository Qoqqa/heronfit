// import '/auth/supabase_auth/auth_util.dart';
// import '/backend/supabase/supabase.dart';
// import '/components/my_templates_empty_widget.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'dart:ui';
import '../views/workout/workout_widget.dart' show WorkoutWidget;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WorkoutModel extends FlutterFlowModel<WorkoutWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  // WorkoutsRow? newWorkoutID;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}

class Workout {
  final String? id;
  final String? name;

  Workout({this.id, this.name});
}
