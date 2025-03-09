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
  final ScrollController _scrollController = ScrollController();
  
  Timer? _debounce;
  String _searchQuery = '';
  List<Exercise> _exercises = [];
  List<String> _autocompleteSuggestions = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _showAutocomplete = false;
  final ExerciseController _exerciseController = ExerciseController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
    
    // Add scroll listener for infinite scrolling
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Handle scroll events for infinite scrolling
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !_exerciseController.isFetchingMore &&
        _exerciseController.hasMorePages &&
        !_isSearching) {
      _loadMoreExercises();
    }
  }

  // Load initial exercises from API
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
  
  // Load more exercises (pagination)
  Future<void> _loadMoreExercises() async {
    if (_isSearching) return;
    
    try {
      final exercises = await _exerciseController.fetchMoreExercises();
      setState(() {
        _exercises = exercises;
      });
    } catch (e) {
      _showErrorDialog('Error loading more exercises: $e');
    }
  }
  
  // Search exercises by query
  Future<void> _searchExercises(String query) async {
    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    try {
      final exercises = await _exerciseController.searchExercises(query);
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error searching exercises: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }
  
  // Get autocomplete suggestions
  Future<void> _getAutocompleteSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _autocompleteSuggestions = [];
        _showAutocomplete = false;
      });
      return;
    }
    
    try {
      final suggestions = await _exerciseController.getAutocompleteSuggestions(query);
      setState(() {
        _autocompleteSuggestions = suggestions;
        _showAutocomplete = suggestions.isNotEmpty;
      });
    } catch (e) {
      print('Error getting autocomplete suggestions: $e');
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

  // Handle search input changes
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
      });
      
      if (value.isEmpty) {
        // Reset to initial exercises list
        _loadExercises();
      } else {
        // Get autocomplete suggestions
        _getAutocompleteSuggestions(value);
      }
    });
  }
  
  // Handle suggestion selection
  void _onSuggestionSelected(String suggestion) {
    _searchController.text = suggestion;
    setState(() {
      _searchQuery = suggestion;
      _showAutocomplete = false;
    });
    _searchExercises(suggestion);
  }
  
  // Perform search with current query
  void _performSearch() {
    setState(() {
      _showAutocomplete = false;
    });
    _searchExercises(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAutocomplete = false;
        });
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
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    // Search field
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextFormField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: _onSearchChanged,
                        onFieldSubmitted: (_) => _performSearch(),
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
                                      _showAutocomplete = false;
                                    });
                                    _loadExercises();
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
                    
                    // Autocomplete suggestions
                    if (_showAutocomplete)
                      Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          constraints: BoxConstraints(
                            maxHeight: 200,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _autocompleteSuggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = _autocompleteSuggestions[index];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  _capitalizeWords(suggestion),
                                  style: TextStyle(fontSize: 14),
                                ),
                                onTap: () => _onSuggestionSelected(suggestion),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Instructions
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
              
              // Exercise List
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _exercises.isEmpty
                        ? Center(child: Text('No exercises found'))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(16),
                            itemCount: _exercises.length + (_exerciseController.hasMorePages && !_isSearching ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _exercises.length) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final exercise = _exercises[index];

                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.0),
                                child: InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Added ${exercise.name} to workout'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    Navigator.pop(context, exercise);
                                  },
                                  onLongPress: () {
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
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // Exercise image with proper error handling
                                                                                    // Image display section in add_exercise_screen.dart
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                                width: 1.0,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(7.0),
                                              child: exercise.imageUrl.isNotEmpty
                                                  ? Image.network(
                                                      exercise.imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        print('Error loading image: $error');
                                                        print('Image URL: ${exercise.imageUrl}');
                                                        return Center(
                                                          child: Icon(
                                                            Icons.fitness_center,
                                                            size: 28,
                                                            color: Theme.of(context).colorScheme.primary,
                                                          ),
                                                        );
                                                      },
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        if (loadingProgress == null) return child;
                                                        return Center(
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2.0,
                                                            value: loadingProgress.expectedTotalBytes != null
                                                                ? loadingProgress.cumulativeBytesLoaded / 
                                                                    loadingProgress.expectedTotalBytes!
                                                                : null,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Center(
                                                      child: Icon(
                                                        Icons.fitness_center,
                                                        size: 28,
                                                        color: Theme.of(context).colorScheme.primary,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          SizedBox(width: 12.0),

                                          // Exercise details with constraints to prevent overflow
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Exercise Name
                                                Text(
                                                  _capitalizeWords(exercise.name),
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4.0),

                                                // Target muscle with overflow protection
                                                Text(
                                                  'Target Muscle: ${_capitalizeWords(exercise.primaryMuscle)}',
                                                  style: TextStyle(fontSize: 14.0),
                                                  maxLines: 2,
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
