import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heronfit/core/theme.dart';

class RestTimerDialog extends StatefulWidget {
  final Duration initialDuration;

  const RestTimerDialog({
    super.key,
    this.initialDuration = const Duration(seconds: 90), // Default rest time
  });

  @override
  RestTimerDialogState createState() => RestTimerDialogState();
}

class RestTimerDialogState extends State<RestTimerDialog> {
  late Timer _timer;
  late Duration _currentDuration;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.initialDuration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentDuration.inSeconds <= 0) {
        timer.cancel();
        // Optionally add sound/vibration feedback here
        // Navigator.of(context).pop(); // Optionally auto-close
      } else {
        setState(() {
          _currentDuration -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rest Timer'),
      titleTextStyle: HeronFitTheme.textTheme.titleLarge?.copyWith(
        color: HeronFitTheme.primary,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDuration(_currentDuration),
            style: HeronFitTheme.textTheme.displayMedium?.copyWith(
              color: HeronFitTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value:
                _currentDuration.inSeconds /
                widget.initialDuration.inSeconds.clamp(1, double.infinity),
            backgroundColor: HeronFitTheme.textMuted.withAlpha(50),
            valueColor: AlwaysStoppedAnimation<Color>(HeronFitTheme.primary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(
            'Skip Rest',
            style: TextStyle(color: HeronFitTheme.textMuted),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _currentDuration += const Duration(seconds: 15);
            });
          },
          child: const Text('+15s'),
        ),
      ],
    );
  }
}
