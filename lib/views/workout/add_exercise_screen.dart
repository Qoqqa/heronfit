import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/exercise_model.dart';
import '../../controllers/exercise_controller.dart';
import 'exercise_details_screen.dart';

class AddExerciseScreen extends StatefulWidget {
  final String? workoutId;

  const AddExerciseScreen({Key? key, this.workoutId}) : super(key: key);

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  String _searchQuery = '';
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  final ExerciseController _exerciseController = ExerciseController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Load exercises from API
  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final exercises = await _exerciseController.fetchExercises();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading exercises: $e');
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Filter exercises based on search query
  List<Exercise> _getFilteredExercises() {
    if (_searchQuery.isEmpty) {
      return _exercises;
    }

    final query = _searchQuery.toLowerCase();
    return _exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(query) ||
          exercise.targetMuscles.any((muscle) => muscle.toLowerCase().contains(query)) ||
          exercise.bodyParts.any((part) => part.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = _getFilteredExercises();
    
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
            'Add Exercises',
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextFormField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        setState(() {
                          _searchQuery = value;
                        });
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search Exercises...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Use the search bar above to quickly find the exercise you need. Tap to add a new exercise to your workout. Long press on an exercise to view its details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : filteredExercises.isEmpty
                      ? Center(
                          child: Text(
                            'No exercises found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = filteredExercises[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                onTap: () {
                                  // Handle adding exercise to workout
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Added ${exercise.name} to workout'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pop(context, exercise);
                                },
                                onLongPress: () {
                                  // Navigate to exercise details
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ExerciseDetailsScreen(exercise: exercise),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 64.0,
                                          height: 64.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Theme.of(context).colorScheme.secondary,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(2.0),
                                            child: ClipOval(
                                              child: Image.network(
                                                exercise.gifUrl,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded / 
                                                              loadingProgress.expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.fitness_center,
                                                    size: 30,
                                                    color: Theme.of(context).colorScheme.secondary,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _capitalizeWords(exercise.name),
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 4.0),
                                              Text(
                                                exercise.targetMuscles.isNotEmpty
                                                    ? _capitalizeWords(exercise.targetMuscles.join(', '))
                                                    : 'No target muscles specified',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                ),
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
                          },
                        ),
              ),
            ],
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
