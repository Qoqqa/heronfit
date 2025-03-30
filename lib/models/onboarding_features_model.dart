import 'package:flutterflow_ui/flutterflow_ui.dart';
import '../views/onboarding/onboarding_features.dart' show OnboardingFeaturesWidget;
import 'package:flutter/material.dart';

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
