import 'package:flutter/material.dart';
import '../core/recommendation/recommendation_factory.dart';
import '../core/services/workout_recommendation_service.dart';
import '../core/theme.dart';

class RecommendationAlgorithmSelector extends StatefulWidget {
  final WorkoutRecommendationService recommendationService;
  final Function() onAlgorithmChanged;
  
  const RecommendationAlgorithmSelector({
    Key? key,
    required this.recommendationService,
    required this.onAlgorithmChanged,
  }) : super(key: key);
  
  @override
  _RecommendationAlgorithmSelectorState createState() =>
      _RecommendationAlgorithmSelectorState();
}

class _RecommendationAlgorithmSelectorState extends State<RecommendationAlgorithmSelector> {
  late List<Map<String, dynamic>> _algorithms;
  late RecommendationAlgorithm _selectedAlgorithm;
  
  @override
  void initState() {
    super.initState();
    _algorithms = widget.recommendationService.getAvailableAlgorithms();
    _selectedAlgorithm = RecommendationAlgorithm.hybrid;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: HeronFitTheme.bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendation Algorithm',
            style: HeronFitTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: HeronFitTheme.primary.withOpacity(0.3)),
            ),
            child: DropdownButton<RecommendationAlgorithm>(
              value: _selectedAlgorithm,
              isExpanded: true,
              underline: Container(),
              icon: Icon(Icons.arrow_drop_down, color: HeronFitTheme.primary),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(8),
              items: _algorithms.map((algorithm) {
                return DropdownMenuItem<RecommendationAlgorithm>(
                  value: algorithm['algorithm'],
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          algorithm['name'],
                          style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          algorithm['description'],
                          style: HeronFitTheme.textTheme.labelSmall?.copyWith(
                            color: HeronFitTheme.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (RecommendationAlgorithm? value) {
                if (value != null) {
                  setState(() {
                    _selectedAlgorithm = value;
                  });
                  widget.recommendationService.setAlgorithm(value);
                  widget.onAlgorithmChanged();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}