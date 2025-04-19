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
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme =
        HeronFitTheme.textTheme; // Use theme's textTheme
    final Color primaryColor = theme.colorScheme.primary;
    final Color surfaceColor = theme.colorScheme.surface;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              SolarIconsOutline.altArrowLeft,
              color: theme.colorScheme.primary,
              size: 30.0,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Exercise Details',
            style: textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wrap image container with Hero
                Hero(
                  tag: widget.heroTag,
                  // Use nested Containers for double border effect
                  child: Container(
                    padding: const EdgeInsets.all(
                      3.0,
                    ), // Outer border thickness
                    decoration: BoxDecoration(
                      color: primaryColor, // Outer border color
                      borderRadius: BorderRadius.circular(15.0), // Outer radius
                      boxShadow: HeronFitTheme.cardShadow, // Apply shadow here
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(
                        3.0,
                      ), // Inner border thickness
                      decoration: BoxDecoration(
                        color:
                            surfaceColor, // Inner border color (white/surface)
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ), // Inner radius
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
                                          color: primaryColor,
                                          strokeWidth: 2.0,
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) =>
                                          _buildImagePlaceholder(
                                            theme,
                                            textTheme,
                                          ),
                                )
                                : _buildImagePlaceholder(theme, textTheme),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Exercise name
                Text(
                  _capitalizeWords(widget.exercise.name),
                  style: textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),

                // Details Section - No Card, just the Container for layout/shadow
                Container(
                  decoration: BoxDecoration(
                    // Keep the shadow if desired, or remove if not needed
                    boxShadow: HeronFitTheme.cardShadow,
                    // Make background transparent or use background color
                    color:
                        Colors.transparent, // Or theme.colorScheme.background
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              theme,
                              textTheme,
                              SolarIconsOutline.target,
                              'Target:', // Shorten label
                              widget.exercise.primaryMuscle,
                            ),
                            const SizedBox(height: 8.0), // Spacing
                            _buildDetailRow(
                              theme,
                              textTheme,
                              SolarIconsOutline.dumbbellSmall,
                              'Equipment:',
                              widget.exercise.equipment,
                            ),
                            const SizedBox(height: 8.0),
                            _buildDetailRow(
                              theme,
                              textTheme,
                              SolarIconsOutline.layersMinimalistic,
                              'Category:',
                              widget.exercise.category,
                            ),
                            const SizedBox(height: 8.0),
                            _buildDetailRow(
                              theme,
                              textTheme,
                              SolarIconsOutline.ranking,
                              'Level:',
                              widget.exercise.level,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0), // Space between columns
                      // Second Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              theme,
                              textTheme,
                              SolarIconsOutline.bolt,
                              'Force:',
                              widget.exercise.force.isNotEmpty
                                  ? widget.exercise.force
                                  : 'N/A',
                            ),
                            const SizedBox(height: 8.0),
                            // Only show Mechanic if it exists
                            if (widget.exercise.mechanic != null &&
                                widget.exercise.mechanic!.isNotEmpty)
                              Padding(
                                // Add padding to align with others when present
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _buildDetailRow(
                                  theme,
                                  textTheme,
                                  SolarIconsOutline.tuning,
                                  'Mechanic:',
                                  widget.exercise.mechanic!,
                                ),
                              ),
                            _buildDetailRow(
                              theme,
                              textTheme,
                              SolarIconsOutline.body,
                              'Secondary:', // Shorten label
                              widget.exercise.secondaryMuscles.isNotEmpty
                                  ? widget.exercise.secondaryMuscles.join(', ')
                                  : 'None',
                              isList: true,
                            ),
                          ],
                        ),
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
                      color: theme.colorScheme.primary,
                      size: 26, // Adjust size as needed
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Instructions',
                      style: textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
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
                          color: theme.colorScheme.surface,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
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
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.exercise.instructions[index],
                                      style: textTheme.bodyMedium,
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
                        color: theme.colorScheme.surfaceVariant.withAlpha(50),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          'No instructions available for this exercise.',
                          style: textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 24.0),
              ],
            ),
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

  // Helper method to build a detail row with label and value
  Widget _buildDetailRow(
    ThemeData theme,
    TextTheme textTheme,
    IconData icon,
    String label,
    String value, {
    bool isList = false, // Keep this parameter if needed elsewhere
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1.0), // Adjust alignment slightly
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ), // Smaller icon
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 75, // Reduced label width
          child: Padding(
            padding: const EdgeInsets.only(
              top: 1.0,
            ), // Adjust alignment slightly
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                // Slightly larger than value
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis, // Prevent label overflow
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _capitalizeWords(value),
            style: textTheme.labelSmall, // Use labelSmall for value
            softWrap: true, // Explicitly allow wrapping
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
