import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'dart:math';
import 'dart:ui';
import '../views/onboarding/onboarding_features.dart' show OnboardingFeaturesWidget;
import 'package:smooth_page_indicator/smooth_page_indicator.dart' as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OnboardingFeaturesModel extends FlutterFlowModel<OnboardingFeaturesWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
