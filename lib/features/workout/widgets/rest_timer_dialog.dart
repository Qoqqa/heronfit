import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heronfit/core/theme.dart';
import 'package:solar_icons/solar_icons.dart';

class RestTimerDialog extends StatefulWidget {
  final Duration initialDuration;
  final VoidCallback onSkip;
  final VoidCallback onTimerEnd;
  final Function(Duration)? onAdjustDuration; // Optional: To update default

  const RestTimerDialog({
    Key? key,
    required this.initialDuration,
    required this.onSkip,
    required this.onTimerEnd,
    this.onAdjustDuration,
  }) : super(key: key);

  @override
  _RestTimerDialogState createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<RestTimerDialog> {
  Timer? _timer;
  late Duration _remainingTime;
  late Duration
  _currentSetDuration; // To track adjustments for onAdjustDuration

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialDuration;
    _currentSetDuration = widget.initialDuration;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingTime <= Duration.zero) {
        timer.cancel();
        widget.onTimerEnd(); // Notify parent timer ended
        if (mounted) {
          Navigator.of(context).pop(); // Close dialog automatically
        }
      } else {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      }
    });
  }

  void _adjustTime(Duration adjustment) {
    final newRemaining = _remainingTime + adjustment;
    final newSetDuration = _currentSetDuration + adjustment;

    if (newRemaining >= Duration.zero) {
      setState(() {
        _remainingTime = newRemaining;
        // Only update _currentSetDuration if the adjustment is valid
        if (newSetDuration >= const Duration(seconds: 15)) {
          // Prevent going below 15s?
          _currentSetDuration = newSetDuration;
          // Optionally notify parent about the adjusted default duration
          widget.onAdjustDuration?.call(_currentSetDuration);
        } else if (adjustment < Duration.zero &&
            _currentSetDuration > const Duration(seconds: 15)) {
          // Allow decreasing down to 15s
          _currentSetDuration = const Duration(seconds: 15);
          widget.onAdjustDuration?.call(_currentSetDuration);
        }
      });
      // Restart timer logic might be needed if the timer was already finished
      // but for +/- buttons, it's usually adjusted while running.
    } else {
      // If adjustment makes it zero or less, treat as skip/end
      _skipTimer();
    }
  }

  void _skipTimer() {
    _timer?.cancel();
    widget.onSkip(); // Notify parent timer was skipped
    if (mounted) {
      Navigator.of(context).pop(); // Close dialog
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(1, '0'); // No need for 2 padding if minutes < 10
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    double progress = 1.0;
    if (widget.initialDuration.inSeconds > 0) {
      progress = _remainingTime.inSeconds / widget.initialDuration.inSeconds;
    }

    return AlertDialog(
      backgroundColor: HeronFitTheme.bgLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      contentPadding: const EdgeInsets.all(24.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rest Timer',
            style: HeronFitTheme.textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: HeronFitTheme.primary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    HeronFitTheme.primary,
                  ),
                ),
                Center(
                  child: Text(
                    _formatDuration(_remainingTime),
                    style: HeronFitTheme.textTheme.displaySmall?.copyWith(
                      color: HeronFitTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(SolarIconsOutline.minusCircle),
                iconSize: 36,
                color: HeronFitTheme.primary,
                onPressed: () => _adjustTime(const Duration(seconds: -15)),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(SolarIconsOutline.addCircle),
                iconSize: 36,
                color: HeronFitTheme.primary,
                onPressed: () => _adjustTime(const Duration(seconds: 15)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _skipTimer,
            child: Text(
              'Skip Rest',
              style: HeronFitTheme.textTheme.labelLarge?.copyWith(
                color: HeronFitTheme.error, // Changed from secondary to error
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
