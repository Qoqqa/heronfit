import 'package:flutter/material.dart';
import '../../controllers/exercise_controller.dart';
import '../../models/exercise_model.dart';
import 'exercise_details_screen.dart';

class AddExerciseScreen extends StatefulWidget {
  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final ExerciseController _controller = ExerciseController();
  List<Exercise> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      List<Exercise> exercises = await _controller.fetchExercises();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading exercises: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Exercise')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return ListTile(
                  leading: Image.network(exercise.gifUrl, width: 50, height: 50),
                  title: Text(exercise.name),
                  subtitle: Text(exercise.targetMuscles.join(', ')),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetailsScreen(exercise: exercise),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
