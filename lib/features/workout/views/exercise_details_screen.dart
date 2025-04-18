import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import 'package:page_transition/page_transition.dart';
import 'package:solar_icons/solar_icons.dart'; // Add this import

class ExerciseDetailsScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailsScreen({Key? key, required this.exercise})
    : super(key: key);

  @override
  _ExerciseDetailsScreenState createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context); // Get theme data

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Set to transparent
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              SolarIconsOutline.altArrowLeft, // Use SolarIcons
              color: theme.colorScheme.primary,
              size: 30.0, // Keep size if needed
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Exercise Details',
            style: TextStyle(
              // Apply standard style
              color: theme.colorScheme.primary,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0, // Keep elevation 0
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.all(16.0), // Reduced padding
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start, // Align all children to the left
                      children: [
                        // Image container
                        // Image container in exercise_details_screen.dart
                        Container(
                          width: double.infinity,
                          height: 250.0,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.background,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10.0,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0.0, 5.0),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2.0,
                            ),
                          ),
                          child:
                              widget.exercise.imageUrl.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6.0),
                                    child: Image.network(
                                      widget.exercise.imageUrl,
                                      width: double.infinity,
                                      height: 250.0,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        print('Error loading image: $error');
                                        print(
                                          'Image URL: ${widget.exercise.imageUrl}',
                                        );
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.fitness_center,
                                                size: 60,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'No image available',
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                  : Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.fitness_center,
                                          size: 60,
                                          color: theme.colorScheme.primary,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'No image available',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                        SizedBox(height: 16.0),

                        // Exercise name
                        Text(
                          _capitalizeWords(widget.exercise.name),
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 8.0),

                        // Exercise details in a column to avoid overflow
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Target Muscle
                            _buildRichText(
                              'Target Muscle:',
                              widget.exercise.primaryMuscle,
                            ),
                            SizedBox(height: 4.0),

                            // Equipment
                            _buildRichText(
                              'Equipment:',
                              widget.exercise.equipment,
                            ),
                            SizedBox(height: 4.0),

                            // Body Part
                            _buildRichText(
                              'Body Part:',
                              widget.exercise.category,
                            ),
                            SizedBox(height: 4.0),

                            // Secondary Muscles (with proper wrapping)
                            _buildRichText(
                              'Secondary Muscles:',
                              widget.exercise.secondaryMuscles.isNotEmpty
                                  ? widget.exercise.secondaryMuscles.join(', ')
                                  : 'None',
                            ),
                          ],
                        ),

                        SizedBox(height: 16.0),
                        Divider(
                          thickness: 2.0,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(height: 8.0),

                        // Instructions section
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 8.0),

                        // Instructions list
                        widget.exercise.instructions.isNotEmpty
                            ? ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: widget.exercise.instructions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${index + 1}. ',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          widget.exercise.instructions[index],
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'No instructions available for this exercise.',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to format text with bold labels
  Widget _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: _capitalizeWords(value),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
      overflow: TextOverflow.visible, // Changed from ellipsis to visible
      maxLines: 5, // Increased from 2 to 5
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
