import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditGoalsWidget extends StatefulWidget {
  const EditGoalsWidget({super.key});

  static String routeName = 'EditGoals';
  static String routePath = '/editGoals';

  @override
  State<EditGoalsWidget> createState() => _EditGoalsWidgetState();
}

class _EditGoalsWidgetState extends State<EditGoalsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController textController1 = TextEditingController();
  final TextEditingController textController2 = TextEditingController();
  final TextEditingController textController3 = TextEditingController();
  final TextEditingController textController4 = TextEditingController();
  final TextEditingController textController5 = TextEditingController();

  @override
  void dispose() {
    textController1.dispose();
    textController2.dispose();
    textController3.dispose();
    textController4.dispose();
    textController5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Edit Goals',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 40,
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 10),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                Icons.radar,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Current Goal',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: 'Weight Loss',
                            items: [
                              DropdownMenuItem(
                                value: 'Weight Loss',
                                child: Text('Weight Loss'),
                              ),
                              DropdownMenuItem(
                                value: 'Gain Muscle',
                                child: Text('Gain Muscle'),
                              ),
                              DropdownMenuItem(
                                value: 'Overall Fitness',
                                child: Text('Overall Fitness'),
                              ),
                            ],
                            onChanged: (val) {},
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).scaffoldBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 40,
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 10),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Starting Weight',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: textController1,
                                  decoration: InputDecoration(
                                    hintText: '50kg on 08 Oct 2024',
                                    filled: true,
                                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(thickness: 2, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current Weight',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: textController2,
                                  decoration: InputDecoration(
                                    hintText: '65 kg',
                                    filled: true,
                                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(thickness: 2, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Goal Weight',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: textController3,
                                  decoration: InputDecoration(
                                    hintText: '75 kg',
                                    filled: true,
                                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(thickness: 2, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Workouts / Week',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: textController4,
                                  decoration: InputDecoration(
                                    hintText: '5',
                                    filled: true,
                                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(thickness: 2, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Minutes / Workout',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: textController5,
                                  decoration: InputDecoration(
                                    hintText: '60',
                                    filled: true,
                                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(thickness: 2, color: Theme.of(context).primaryColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}