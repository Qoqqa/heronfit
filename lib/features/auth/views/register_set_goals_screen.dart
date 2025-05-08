import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/widgets/loading_indicator.dart';
import '../controllers/registration_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Added import

// Define a data class for goal items
class GoalItem {
  final String imagePath;
  final String
  title; // Kept for data model consistency, not displayed in carousel
  final String
  description; // Kept for data model consistency, not displayed in carousel
  final String backendValue; // Value to be stored in Supabase

  const GoalItem({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.backendValue,
  });
}

class RegisterSetGoalsScreen extends ConsumerStatefulWidget {
  const RegisterSetGoalsScreen({super.key});

  @override
  ConsumerState<RegisterSetGoalsScreen> createState() =>
      _RegisterSetGoalsScreenState();
}

class _RegisterSetGoalsScreenState
    extends ConsumerState<RegisterSetGoalsScreen> {
  bool _isLoading = false;
  // viewportFraction allows peeking of next/previous items
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  final List<GoalItem> _goals = [
    const GoalItem(
      imagePath: 'assets/images/goals_weight_loss.webp',
      title: 'Weight Loss & Confidence Boost',
      description: 'Reach your ideal weight and unlock newfound self-esteem.',
      backendValue: 'lose_weight',
    ),
    const GoalItem(
      imagePath: 'assets/images/goals_overall_fitness.webp',
      title: 'Boost Energy & Fitness',
      description:
          'Feel more energized, move with ease, and improve your overall health.',
      backendValue: 'general_fitness',
    ),
    const GoalItem(
      imagePath: 'assets/images/goals_build_muscle.webp',
      title: 'Build Muscle, Gain Power',
      description:
          'Become stronger, more capable, and build a physique you\'re proud of.',
      backendValue: 'build_muscle',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final initialGoal = ref.read(registrationProvider).goal;
    if (initialGoal.isNotEmpty) {
      final initialIndex = _goals.indexWhere(
        (goal) => goal.backendValue == initialGoal,
      );
      if (initialIndex != -1) {
        _currentPage = initialIndex;
      }
    }
    if (_goals.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(registrationProvider.notifier)
              .updateGoal(_goals[_currentPage].backendValue);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationNotifier = ref.read(registrationProvider.notifier);

    final PageController pageControllerWithInitial = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.75,
    );

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Let\'s Conquer Your Fitness Goals',
                      textAlign: TextAlign.center,
                      style: HeronFitTheme.textTheme.titleLarge?.copyWith(
                        color: HeronFitTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // const SizedBox(height: 8),
                    Text(
                      'Pick your focus, and we\'ll tailor your path to success.',
                      textAlign: TextAlign.center,
                      style: HeronFitTheme.textTheme.labelLarge?.copyWith(
                        color: HeronFitTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: pageControllerWithInitial,
                        itemCount: _goals.length,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                          registrationNotifier.updateGoal(
                            _goals[page].backendValue,
                          );
                        },
                        itemBuilder: (context, index) {
                          final goal = _goals[index];

                          return AnimatedBuilder(
                            animation: pageControllerWithInitial,
                            builder: (context, child) {
                              double scaleValue = 1.0;
                              double verticalPaddingValue = 0.0;

                              if (pageControllerWithInitial
                                  .position
                                  .haveDimensions) {
                                double page = pageControllerWithInitial.page!;
                                scaleValue = (1 - ((page - index).abs() * 0.15))
                                    .clamp(0.85, 1.0);
                                verticalPaddingValue = ((page - index).abs() *
                                        20.0)
                                    .clamp(0.0, 25.0);
                              } else {
                                scaleValue = index == _currentPage ? 1.0 : 0.85;
                                verticalPaddingValue =
                                    index == _currentPage ? 0.0 : 25.0;
                              }

                              return Transform.scale(
                                scale: scaleValue,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: verticalPaddingValue,
                                    horizontal: 4.0,
                                  ),
                                  child: Image.asset(
                                    goal.imagePath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SmoothPageIndicator(
                      controller: pageControllerWithInitial,
                      count: _goals.length,
                      effect: WormEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        activeDotColor: HeronFitTheme.primary,
                        dotColor: HeronFitTheme.primary.withOpacity(0.5),
                        paintStyle: PaintingStyle.fill,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 32.0,
                    left: 24.0,
                    right: 24.0,
                  ),
                  child: const LoadingIndicator(),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 32.0,
                    left: 24.0,
                    right: 24.0,
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      try {
                        await registrationNotifier.initiateSignUp();
                        if (mounted) {
                          context.pushNamed(AppRoutes.registerVerify);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error: ${e.toString().replaceFirst("Exception: ", "")}',
                              ),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HeronFitTheme.primary,
                      foregroundColor: HeronFitTheme.bgLight,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: HeronFitTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Confirm & Continue'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
