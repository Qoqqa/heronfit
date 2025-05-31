import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:heronfit/core/theme.dart'; // Import HeronFitTheme
import '../models/exercise_model.dart';
import 'package:solar_icons/solar_icons.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final Exercise exercise;
  final String heroTag; // Add heroTag parameter

  const ExerciseDetailsScreen({
    super.key, // Use super parameter
    required this.exercise,
    required this.heroTag, // Require heroTag
  });

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: HeronFitTheme.primary,
              size: 30,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Exercise Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wrap image container with Hero
              Hero(
                tag: widget.heroTag,
                // Use nested Containers for double border effect
                child: Container(
                  padding: const EdgeInsets.all(3.0), // Outer border thickness
                  decoration: BoxDecoration(
                    color: HeronFitTheme.primary, // Outer border color
                    borderRadius: BorderRadius.circular(15.0), // Outer radius
                    boxShadow: HeronFitTheme.cardShadow, // Apply shadow here
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(
                      3.0,
                    ), // Inner border thickness
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context)
                              .colorScheme
                              .surface, // Inner border color (white/surface)
                      borderRadius: BorderRadius.circular(12.0), // Inner radius
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        9.0,
                      ), // Clip radius (Inner - padding)
                      child:
                          widget.exercise.imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: widget.exercise.imageUrl,
                                width: double.infinity,
                                height: 250.0,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        color: HeronFitTheme.primary,
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) =>
                                        _buildImagePlaceholder(
                                          Theme.of(context),
                                          HeronFitTheme.textTheme,
                                        ),
                              )
                              : _buildImagePlaceholder(
                                Theme.of(context),
                                HeronFitTheme.textTheme,
                              ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Exercise name
              Text(
                _capitalizeWords(widget.exercise.name),
                style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                  color: HeronFitTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),

              // Details Section - Icons, labels, and values aligned vertically
              Container(
                decoration: BoxDecoration(
                  color:
                      Theme.of(context)
                          .colorScheme
                          .surface, // Background color for the container
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: HeronFitTheme.cardShadow, // Apply shadow here
                ),
                padding: const EdgeInsets.all(
                  16.0,
                ), // Add padding inside the container
                child: Column(
                  // Use a Column for vertical arrangement of detail rows
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Build each detail row using the helper
                    _buildDetailsRowContent(
                      context,
                      SolarIconsOutline.target,
                      'Target:',
                      _capitalizeWords(widget.exercise.primaryMuscle),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ), // Adjusted spacing between rows
                    _buildDetailsRowContent(
                      context,
                      SolarIconsOutline.dumbbellSmall,
                      'Equipment:',
                      _capitalizeWords(widget.exercise.equipment),
                    ),
                    const SizedBox(height: 8.0), // Adjusted spacing
                    _buildDetailsRowContent(
                      context,
                      SolarIconsOutline.bolt,
                      'Force:',
                      _capitalizeWords(
                        widget.exercise.force.isNotEmpty
                            ? widget.exercise.force
                            : 'N/A',
                      ),
                    ),
                    const SizedBox(height: 8.0), // Adjusted spacing
                    _buildDetailsRowContent(
                      context,
                      SolarIconsOutline.layersMinimalistic,
                      'Category:',
                      _capitalizeWords(widget.exercise.category),
                    ),
                    const SizedBox(height: 8.0), // Adjusted spacing
                    _buildDetailsRowContent(
                      context,
                      SolarIconsOutline.ranking,
                      'Level:',
                      _capitalizeWords(widget.exercise.level),
                    ),
                    // Only show Mechanic if it exists, add spacing before and after it
                    if (widget.exercise.mechanic != null &&
                        widget.exercise.mechanic!.isNotEmpty) ...[
                      const SizedBox(height: 8.0), // Adjusted spacing
                      _buildDetailsRowContent(
                        context,
                        SolarIconsOutline.tuning,
                        'Mechanic:',
                        _capitalizeWords(widget.exercise.mechanic!),
                      ),
                    ],
                    const SizedBox(
                      height: 8.0,
                    ), // Adjusted spacing before Secondary
                    _buildDetailsRowContent(
                      context,
                      SolarIconsOutline.body,
                      'Secondary:',
                      _capitalizeWords(
                        widget.exercise.secondaryMuscles.isNotEmpty
                            ? widget.exercise.secondaryMuscles.join(', ')
                            : 'None',
                      ),
                      // isList: true, // No longer needed in helper with this layout
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Instructions Section Title
              Row(
                children: [
                  Icon(
                    SolarIconsOutline.listCheck,
                    color: HeronFitTheme.primary,
                    size: 26, // Adjust size as needed
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Instructions',
                    style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                      color: HeronFitTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // Instructions List (as Cards)
              widget.exercise.instructions.isNotEmpty
                  ? Column(
                    children: List.generate(
                      widget.exercise.instructions.length,
                      (index) => Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        color: Theme.of(context).colorScheme.surface,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: HeronFitTheme.cardShadow,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 16.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ',
                                  style: HeronFitTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: HeronFitTheme.primary,
                                      ),
                                ),
                                Expanded(
                                  child: Text(
                                    widget.exercise.instructions[index],
                                    style: HeronFitTheme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  : Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withAlpha(50),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        'No instructions available for this exercise.',
                        style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build placeholder for image
  Widget _buildImagePlaceholder(ThemeData theme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            SolarIconsOutline.dumbbellLargeMinimalistic,
            size: 60,
            color: theme.colorScheme.primary.withAlpha(150),
          ),
          const SizedBox(height: 8),
          Text(
            'No image available',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a detail row with icon, label, and value
  // Adjusted to align icon and label to the left, and value to the right
  Widget _buildDetailsRowContent(
    BuildContext context, // Added BuildContext to access Theme
    IconData icon,
    String label,
    String value,
    // Removed isList as it's not used in this layout
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0), // Space after icon
          child: Icon(icon, size: 18, color: theme.colorScheme.primary),
        ),
        // Label text - takes only the space it needs
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          // Removed overflow property here to let it wrap if necessary
        ),
        const SizedBox(width: 4.0), // Small space between label and value
        Expanded(
          // Allow the value text to take up the remaining space and push to the right
          child: Text(
            value,
            style: textTheme.labelSmall, // Use labelSmall for value
            textAlign: TextAlign.right, // Align value text to the right
            softWrap: true, // Allow wrapping
          ),
        ),
      ],
    );
  }

  // Helper method to capitalize words
  String _capitalizeWords(String text) {
    if (text.isEmpty) return '';
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
