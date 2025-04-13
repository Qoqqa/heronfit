import 'package:flutter/material.dart';
import 'dart:async';
import '../models/exercise_model.dart';
import '../controllers/exercise_controller.dart';
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

  List<String> _availableEquipment = [];
  List<String> _selectedEquipment = [];
  bool _isFilterExpanded = false;
  bool _isLoadingEquipment = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _loadAvailableEquipment();
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_exerciseController.isFetchingMore &&
        _exerciseController.hasMorePages &&
        !_isSearching) {
      _loadMoreExercises();
    }
  }

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

  Future<void> _searchExercises(String query) async {
    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    try {
      final exercises = await _exerciseController.searchExercisesWithFilter(
        query: query,
        equipmentFilter: _selectedEquipment.isEmpty ? null : _selectedEquipment,
      );
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

  Future<void> _getAutocompleteSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _autocompleteSuggestions = [];
        _showAutocomplete = false;
      });
      return;
    }

    try {
      final suggestions = await _exerciseController.getAutocompleteSuggestions(
        query,
      );
      setState(() {
        _autocompleteSuggestions = suggestions;
        _showAutocomplete = suggestions.isNotEmpty;
      });
    } catch (e) {
      print('Error getting autocomplete suggestions: $e');
    }
  }

  Future<void> _loadAvailableEquipment() async {
    setState(() {
      _isLoadingEquipment = true;
    });

    try {
      final equipment = await _exerciseController.getAvailableEquipment();
      setState(() {
        _availableEquipment = equipment;
        _isLoadingEquipment = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEquipment = false;
      });
      print('Error loading equipment: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
      });

      if (value.isEmpty) {
        _loadExercises();
      } else {
        _getAutocompleteSuggestions(value);
      }
    });
  }

  void _onSuggestionSelected(String suggestion) {
    _searchController.text = suggestion;
    setState(() {
      _searchQuery = suggestion;
      _showAutocomplete = false;
    });
    _searchExercises(suggestion);
  }

  void _performSearch() {
    setState(() {
      _showAutocomplete = false;
    });
    _searchExercises(_searchQuery);
  }

  void _toggleEquipment(String equipment) {
    setState(() {
      if (_selectedEquipment.contains(equipment)) {
        _selectedEquipment.remove(equipment);
      } else {
        _selectedEquipment.add(equipment);
      }
    });
    _searchExercises(_searchQuery);
  }

  void _clearFilters() {
    setState(() {
      _selectedEquipment.clear();
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
          actions: [
            IconButton(
              icon: Icon(
                Icons.filter_list,
                color:
                    _selectedEquipment.isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Stack(
                  children: [
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey),
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
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.8),
                        ),
                      ),
                    ),

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
                          constraints: BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _autocompleteSuggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion =
                                  _autocompleteSuggestions[index];
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

              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _isFilterExpanded ? null : 0,
                child:
                    _isFilterExpanded
                        ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Filter by Equipment',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  if (_selectedEquipment.isNotEmpty)
                                    TextButton(
                                      onPressed: _clearFilters,
                                      child: Text('Clear All'),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size(50, 30),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8),
                              _isLoadingEquipment
                                  ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                  : Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children:
                                        _availableEquipment.map((equipment) {
                                          final isSelected = _selectedEquipment
                                              .contains(equipment);
                                          return FilterChip(
                                            label: Text(
                                              _capitalizeWords(equipment),
                                            ),
                                            selected: isSelected,
                                            onSelected:
                                                (_) =>
                                                    _toggleEquipment(equipment),
                                            backgroundColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                            selectedColor: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.2),
                                            checkmarkColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              side: BorderSide(
                                                color:
                                                    isSelected
                                                        ? Theme.of(
                                                          context,
                                                        ).colorScheme.primary
                                                        : Colors.grey
                                                            .withOpacity(0.5),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                              SizedBox(height: 8),
                              Divider(),
                            ],
                          ),
                        )
                        : SizedBox.shrink(),
              ),

              if (_selectedEquipment.isNotEmpty && !_isFilterExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Filtered by ${_selectedEquipment.length} equipment types',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: _clearFilters,
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Tap to add an exercise to your workout. Long press for details. Use filters to find equipment-specific exercises.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(height: 8),

              Expanded(
                child:
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : _exercises.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 64,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No exercises found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              if (_selectedEquipment.isNotEmpty) ...[
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _clearFilters,
                                  child: Text('Clear Filters'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount:
                              _exercises.length +
                              (_exerciseController.hasMorePages && !_isSearching
                                  ? 1
                                  : 0),
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
                                      content: Text(
                                        'Added ${exercise.name} to workout',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pop(context, exercise);
                                },
                                onLongPress: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ExerciseDetailsScreen(
                                            exercise: exercise,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.5),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              7.0,
                                            ),
                                            child:
                                                exercise.imageUrl.isNotEmpty
                                                    ? Image.network(
                                                      exercise.imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Center(
                                                          child: Icon(
                                                            Icons
                                                                .fitness_center,
                                                            size: 28,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary,
                                                          ),
                                                        );
                                                      },
                                                      loadingBuilder: (
                                                        context,
                                                        child,
                                                        loadingProgress,
                                                      ) {
                                                        if (loadingProgress ==
                                                            null)
                                                          return child;
                                                        return Center(
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2.0,
                                                            value:
                                                                loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                            .cumulativeBytesLoaded /
                                                                        loadingProgress
                                                                            .expectedTotalBytes!
                                                                    : null,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                    : Center(
                                                      child: Icon(
                                                        Icons.fitness_center,
                                                        size: 28,
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                        SizedBox(width: 12.0),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _capitalizeWords(exercise.name),
                                                style: TextStyle(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4.0),
                                              Text(
                                                'Target: ${_capitalizeWords(exercise.primaryMuscle)}',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Equipment: ${_capitalizeWords(exercise.equipment)}',
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.7),
                                                ),
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
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
