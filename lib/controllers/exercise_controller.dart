import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise_model.dart';

class ExerciseController {
  static const String apiUrl = 'https://exercisedb-api.vercel.app/api/v1/exercises';

  // Fetch exercises from the API
  Future<List<Exercise>> fetchExercises() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Log the raw response for debugging
        print('Raw API response: ${response.body.substring(0, min(200, response.body.length))}...');
        
        final dynamic jsonData = json.decode(response.body);
        
        // Handle the response structure
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('success') && jsonData.containsKey('data')) {
          final data = jsonData['data'];
          
          // Check if data contains exercises directly
          if (data is Map<String, dynamic> && data.containsKey('exercises')) {
            List<dynamic> exercisesJson = data['exercises'];
            return exercisesJson.map((json) => Exercise.fromJson(json)).toList();
          } else if (data is List) {
            // Fallback if data is directly a list
            return data.map((json) => Exercise.fromJson(json)).toList();
          } else {
            print('Unexpected data structure: ${data.runtimeType}');
            throw Exception('Unexpected data structure');
          }
        } else if (jsonData is List) {
          // Format: Direct array of exercises
          return jsonData.map((json) => Exercise.fromJson(json)).toList();
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
