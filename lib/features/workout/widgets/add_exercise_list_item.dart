import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/features/workout/models/exercise_model.dart';
import 'package:heronfit/features/workout/views/exercise_details_screen.dart';
import 'package:solar_icons/solar_icons.dart';

// Define function types for callbacks
typedef HighlightTextBuilder =
    TextSpan Function(String text, String highlight, TextStyle style);
typedef CapitalizeWordsFunc = String Function(String text);

class AddExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final String searchQuery;
  final HighlightTextBuilder buildHighlightedText;
  final CapitalizeWordsFunc capitalizeWords;

  const AddExerciseListItem({
    super.key,
    required this.exercise,
    required this.searchQuery,
    required this.buildHighlightedText,
    required this.capitalizeWords,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = HeronFitTheme.textTheme;
    final Color primaryColor = theme.colorScheme.primary;
    final Color surfaceColor = theme.colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        // Add highlight color for long press feedback
        highlightColor: primaryColor.withAlpha(30), // Subtle primary highlight
        splashColor: primaryColor.withAlpha(20), // Subtle primary splash
        borderRadius: BorderRadius.circular(8.0), // Match container radius
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${exercise.name} to workout'),
              duration: const Duration(seconds: 2),
              backgroundColor: HeronFitTheme.primary,
            ),
          );
          context.pop(exercise);
        },
        onLongPress: () {
          // Add haptic feedback for long press
          HapticFeedback.mediumImpact();
          FocusScope.of(context).unfocus();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExerciseDetailsScreen(exercise: exercise),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: HeronFitTheme.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Nested CircleAvatars for double border effect
                CircleAvatar(
                  radius: 32, // Outer radius (defines total size 64x64)
                  backgroundColor: primaryColor, // Outer border color (primary)
                  child: CircleAvatar(
                    radius: 30, // Radius for white border (Outer - 2dp)
                    backgroundColor:
                        surfaceColor, // Middle border color (white/surface)
                    child: CircleAvatar(
                      radius: 28, // Inner radius for image/icon (Middle - 2dp)
                      backgroundColor: primaryColor.withAlpha(
                        51,
                      ), // Placeholder bg
                      backgroundImage:
                          exercise.imageUrl.isNotEmpty
                              ? CachedNetworkImageProvider(exercise.imageUrl)
                              : null,
                      child:
                          exercise.imageUrl.isEmpty
                              ? Icon(
                                SolarIconsOutline.dumbbellSmall,
                                size: 26, // Icon size
                                color: primaryColor,
                              )
                              : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: buildHighlightedText(
                          capitalizeWords(exercise.name),
                          searchQuery,
                          textTheme.titleMedium!.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 0.0),
                      Text(
                        capitalizeWords(exercise.primaryMuscle),
                        style: textTheme.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
