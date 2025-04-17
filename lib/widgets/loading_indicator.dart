import 'package:flutter/material.dart';
import 'package:heronfit/core/theme.dart';

/// A simple, centered circular progress indicator using the app's primary color.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: HeronFitTheme.primary),
    );
  }
}
