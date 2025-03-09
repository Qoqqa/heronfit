import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';
import 'package:page_transition/page_transition.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailsScreen({Key? key, required this.exercise}) : super(key: key);

  @override
  _ExerciseDetailsScreenState createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 30.0,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Exercise Details',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Image container
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 300.0,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 40.0,
                                    color: Colors.black.withOpacity(0.1),
                                    offset: Offset(0.0, 10.0),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.fade,
                                        child: _ExpandedImageView(
                                          image: Image.network(
                                            widget.exercise.gifUrl,
                                            fit: BoxFit.contain,
                                          ),
                                          tag: widget.exercise.gifUrl,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: widget.exercise.gifUrl,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        widget.exercise.gifUrl,
                                        width: double.infinity,
                                        height: 300.0,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.fitness_center,
                                              size: 60,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        
                        // Exercise details
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                                  child: Text(
                                    _capitalizeWords(widget.exercise.name),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                // First row of details
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Target Muscle: ',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onBackground,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          TextSpan(
                                            text: widget.exercise.targetMuscles.isNotEmpty
                                                ? _capitalizeWords(widget.exercise.targetMuscles.first)
                                                : 'None',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onBackground,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12.0),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Equipment: ',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onBackground,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          TextSpan(
                                            text: widget.exercise.equipments.isNotEmpty
                                                ? _capitalizeWords(widget.exercise.equipments.first)
                                                : 'None',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onBackground,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // Second row of details
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Body Part: ',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onBackground,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          TextSpan(
                                            text: widget.exercise.bodyParts.isNotEmpty
                                                ? _capitalizeWords(widget.exercise.bodyParts.first)
                                                : 'None',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onBackground,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12.0),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Secondary Muscles: ',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onBackground,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            TextSpan(
                                              text: widget.exercise.secondaryMuscles.isNotEmpty
                                                  ? _capitalizeWords(widget.exercise.secondaryMuscles.join(', '))
                                                  : 'None',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onBackground,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Divider(
                              thickness: 2.0,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(height: 8.0),
                            
                            // Instructions section
                            Text(
                              'Instructions',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: widget.exercise.instructions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          style: TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
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

  String _capitalizeWords(String text) {
    if (text.isEmpty) return '';
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

// A simple expanded image view widget
class _ExpandedImageView extends StatelessWidget {
  final Image image;
  final String tag;

  const _ExpandedImageView({
    Key? key,
    required this.image,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: tag,
            child: image,
          ),
        ),
      ),
    );
  }
}
