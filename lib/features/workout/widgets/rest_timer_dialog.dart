import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heronfit/core/theme.dart';
import 'package:solar_icons/solar_icons.dart';

class RestTimerDialog extends StatefulWidget {
  final Duration initialDuration;
  final VoidCallback onSkip;
  final VoidCallback onTimerEnd;
  final Function(Duration)? onAdjustDuration; // Optional: To update default
  final String exerciseName; // Added
  final int setNumber; // Added

  const RestTimerDialog({
    Key? key,
    required this.initialDuration,
    required this.onSkip,
    required this.onTimerEnd,
    this.onAdjustDuration,
    required this.exerciseName, // Added
    required this.setNumber, // Added
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
    // Ensure initialDuration is not zero to avoid division by zero
    if (widget.initialDuration.inSeconds > 0) {
      progress = _remainingTime.inSeconds / widget.initialDuration.inSeconds;
    }

    // Prevent progress from going below 0 if timer overshoots slightly
    progress = progress.clamp(0.0, 1.0);

    // Get screen width for potentially responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    // Aim for a dialog width that's a significant portion of the screen, but not full width
    final dialogWidth = screenWidth * 0.85;
    // Make the timer circle size relative to the dialog width
    final timerSize = dialogWidth * 0.6;

    return AlertDialog(
      backgroundColor: HeronFitTheme.bgLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ), // Even larger radius
      contentPadding: const EdgeInsets.symmetric(
        vertical: 32.0,
        horizontal: 24.0,
      ),
      // Constrain the width of the dialog
      insetPadding: EdgeInsets.symmetric(
        horizontal: (screenWidth - dialogWidth) / 2,
        vertical: 24.0,
      ),
      content: SizedBox(
        width: dialogWidth, // Apply the calculated width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep height determined by content
          children: [
            Text(
              'Rest Timer',
              style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                color: HeronFitTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.exerciseName} - Set ${widget.setNumber}',
              textAlign: TextAlign.center,
              style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                color: HeronFitTheme.textMuted,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: timerSize, // Use calculated size
              height: timerSize, // Use calculated size
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 14, // Slightly thicker stroke
                    backgroundColor: HeronFitTheme.primary.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      HeronFitTheme.primary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text(
                      _formatDuration(_remainingTime),
                      // Adjust text style based on size if needed, displayMedium might be too large
                      style: HeronFitTheme.textTheme.displaySmall?.copyWith(
                        color: HeronFitTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAdjustButton(
                  SolarIconsBold.minusSquare,
                  const Duration(seconds: -15),
                ),
                const SizedBox(width: 24), // Increased spacing
                _buildAdjustButton(
                  SolarIconsBold.addSquare,
                  const Duration(seconds: 15),
                ),
              ],
            ),
            const SizedBox(height: 32), // Increased spacing
            // Change to ElevatedButton for background color
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HeronFitTheme.error, // Red background
                foregroundColor: Colors.white, // White text
                minimumSize: const Size(150, 48), // Ensure decent button size
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Rounded corners
                ),
                textStyle: HeronFitTheme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _skipTimer,
              child: const Text('Skip Rest'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for adjustment buttons
  Widget _buildAdjustButton(IconData icon, Duration adjustment) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 48, // Increased icon size
      color: HeronFitTheme.primary,
      padding: EdgeInsets.zero, // Remove default padding if needed
      constraints:
          const BoxConstraints(), // Remove default constraints if needed
      onPressed: () => _adjustTime(adjustment),
    );
  }
}
