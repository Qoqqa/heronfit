import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise_model.dart';

class ExerciseController {
  static const String baseUrl = 'https://exercisedb-api.vercel.app/api/v1';
  static const String exercisesUrl = '$baseUrl/exercises';
  static const String autocompleteUrl = '$baseUrl/exercises/autocomplete';
  
  // Track pagination state
  String? _nextPageUrl;
  bool _hasMorePages = true;
  List<Exercise> _cachedExercises = [];
  bool _isFetchingMore = false;

  // Get current cached exercises
  List<Exercise> get cachedExercises => _cachedExercises;
  
  // Check if there are more pages available
  bool get hasMorePages => _hasMorePages;
  
  // Check if currently fetching more data
  bool get isFetchingMore => _isFetchingMore;

  // Reset pagination state
  void resetPagination() {
    _nextPageUrl = null;
    _hasMorePages = true;
    _cachedExercises = [];
    _isFetchingMore = false;
  }

  // Fetch first page of exercises
  Future<List<Exercise>> fetchExercises() async {
    resetPagination();
    return _fetchExercisesPage(exercisesUrl);
  }
  
  // Fetch next page of exercises
  Future<List<Exercise>> fetchMoreExercises() async {
    if (!_hasMorePages || _isFetchingMore) {
      return _cachedExercises;
    }
    
    _isFetchingMore = true;
    
    try {
      if (_nextPageUrl != null) {
        await _fetchExercisesPage(_nextPageUrl!);
      }
      return _cachedExercises;
    } finally {
      _isFetchingMore = false;
    }
  }
  
  // Search for exercises by name, muscle, etc.
  Future<List<Exercise>> searchExercises(String query) async {
    if (query.trim().isEmpty) {
      return _cachedExercises;
    }
    
    try {
      final url = '$exercisesUrl?search=$query';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('success') && jsonData.containsKey('data')) {
          final data = jsonData['data'];
          
          if (data is Map<String, dynamic> && data.containsKey('exercises')) {
            List<dynamic> exercisesJson = data['exercises'];
            return exercisesJson.map((json) => Exercise.fromJson(json)).toList();
          }
        }
        
        print('Unexpected search response structure: ${jsonData.runtimeType}');
        throw Exception('Unexpected search response structure');
      } else {
        print('Failed to search exercises: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to search exercises');
      }
    } catch (e) {
      print('Error searching exercises: $e');
      throw Exception('Error searching exercises: $e');
    }
  }
  
  // Get autocomplete suggestions
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    
    try {
      final url = '$autocompleteUrl?search=$query';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('success') && jsonData.containsKey('data')) {
          List<dynamic> suggestions = jsonData['data'];
          return suggestions.map((item) => item.toString()).toList();
        }
        
        print('Unexpected autocomplete response structure: ${jsonData.runtimeType}');
        throw Exception('Unexpected autocomplete response structure');
      } else {
        print('Failed to get autocomplete suggestions: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to get autocomplete suggestions');
      }
    } catch (e) {
      print('Error getting autocomplete suggestions: $e');
      throw Exception('Error getting autocomplete suggestions: $e');
    }
  }

  // Internal method to fetch exercises with pagination
  Future<List<Exercise>> _fetchExercisesPage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Log the raw response for debugging
        print('Raw API response: ${response.body.substring(0, min(200, response.body.length))}...');
        
        final dynamic jsonData = json.decode(response.body);
        
        // Handle the response structure
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('success') && jsonData.containsKey('data')) {
          final data = jsonData['data'];
          
          if (data is Map<String, dynamic>) {
            // Update pagination information
            _nextPageUrl = data['nextPage'];
            _hasMorePages = _nextPageUrl != null;
            
            if (data.containsKey('exercises')) {
              List<dynamic> exercisesJson = data['exercises'];
              final newExercises = exercisesJson.map((json) => Exercise.fromJson(json)).toList();
              
              // Add new exercises to cache
              _cachedExercises.addAll(newExercises);
              return _cachedExercises;
            }
          }
          
          print('Unexpected data structure: ${data.runtimeType}');
          throw Exception('Unexpected data structure');
        } else {
          print('Unexpected API response structure: ${jsonData.runtimeType}');
          throw Exception('Unexpected API response structure');
        }
      } else {
        print('Failed to load exercises: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to load exercises');
      }
    } catch (e) {
      print('Error fetching exercises: $e');
      throw Exception('Error fetching exercises: $e');
    }
  }
}

// Helper function to get the minimum of two integers
int min(int a, int b) => a < b ? a : b;
