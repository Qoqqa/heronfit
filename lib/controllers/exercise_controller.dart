import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise_model.dart';
import '../core/services/supabase_client.dart';

class ExerciseController {
  static const int limit = 10;

  // Pagination state
  int _currentPage = 0;
  bool _hasMorePages = true;
  List<Exercise> _cachedExercises = [];
  bool _isFetchingMore = false;

  List<Exercise> get cachedExercises => _cachedExercises;
  bool get hasMorePages => _hasMorePages;
  bool get isFetchingMore => _isFetchingMore;

  void resetPagination() {
    _currentPage = 0;
    _hasMorePages = true;
    _cachedExercises = [];
    _isFetchingMore = false;
  }

  // Fetch first page of exercises
  Future<List<Exercise>> fetchExercises() async {
    resetPagination();
    return _fetchExercisesPage();
  }

  // Fetch next page of exercises (pagination)
  Future<List<Exercise>> fetchMoreExercises() async {
    if (!_hasMorePages || _isFetchingMore) return _cachedExercises;

    _isFetchingMore = true;
    try {
      await _fetchExercisesPage();
      return _cachedExercises;
    } finally {
      _isFetchingMore = false;
    }
  }

  // Search exercises
  Future<List<Exercise>> searchExercises(String query) async {
    if (query.trim().isEmpty) {
      return _cachedExercises;
    }

    try {
      final data = await SupabaseClientManager.client
          .from('exercises')
          .select()
          .ilike('name', '%$query%')
          .limit(limit);

      return data.map((json) => Exercise.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error searching exercises: $e');
    }
  }

  // Autocomplete suggestions
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final data = await SupabaseClientManager.client
          .from('exercises')
          .select('name')
          .ilike('name', '%$query%')
          .limit(limit);

      return data.map((item) => item['name'].toString()).toList();
    } catch (e) {
      throw Exception('Error getting autocomplete suggestions: $e');
    }
  }

  // Fetch exercises with pagination
  Future<List<Exercise>> _fetchExercisesPage() async {
    try {
      final data = await SupabaseClientManager.client
          .from('exercises')
          .select()
          .range(_currentPage * limit, (_currentPage + 1) * limit - 1);

      final newExercises = data.map((json) => Exercise.fromJson(json)).toList();

      _cachedExercises.addAll(newExercises);
      _hasMorePages = newExercises.length == limit;
      _currentPage++;
      return _cachedExercises;
    } catch (e) {
      throw Exception('Error fetching exercises: $e');
    }
  }
}
