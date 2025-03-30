import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'progress_photo_list.dart'; // Import the ProgressPhotosListWidget
import 'view_progress_photo.dart'; // Import the ViewProgressPhotosWidget
import 'update_weight.dart';

// Initialize Supabase Client
final supabaseClient = Supabase.instance.client;

class ProgressTrackerWidget extends StatefulWidget {
  const ProgressTrackerWidget({super.key});

  static String routeName = 'ProgressTracker';
  static String routePath = '/progressTracker';

  @override
  State<ProgressTrackerWidget> createState() => _ProgressTrackerWidgetState();
}

class _ProgressTrackerWidgetState extends State<ProgressTrackerWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _progressData = []; // Store fetched data
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProgressData(); // Fetch data on initialization
  }

 Future<void> _fetchProgressData() async {
  try {
    // Get the current user
    final user = supabaseClient.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to view progress data!')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Fetch data filtered by the user's email
    final response = await supabaseClient
        .from('update_weight')
        .select('date, weight, pic') // Select required columns
        .eq('email', user.email!) // Filter by the user's email
        .order('id', ascending: false); // Order by date (most recent first)

    setState(() {
      _progressData = List<Map<String, dynamic>>.from(response as List<dynamic>);
    
      _isLoading = false;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching data: $e')),
    );
    setState(() {
      _isLoading = false;
    });
  }
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
            'Progress',
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
          child: Padding(
            padding: EdgeInsets.all(24),
            child: _isLoading
                ? Center(child: CircularProgressIndicator()) // Show loading indicator
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Weight',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '3 Months',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 40,
                                color: Colors.black26,
                                offset: Offset(0, 10),
                              )
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Weight',
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                color: Theme.of(context).primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Align(
                                          alignment: AlignmentDirectional(-1, 0),
                                          child: Text(
                                            'Last 90 Days',
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add,
                                        color: Theme.of(context).primaryColor,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const UpdateWeightWidget(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.grey[200], // Placeholder for the graph
                                  child: Center(
                                    child: Text(
                                      'Graph Placeholder',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(-1, 0),
                              child: Text(
                                'Progress Photos',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProgressPhotosListWidget(),
                                  ),
                                );
                              },
                              child: Text(
                                'See All',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          primary: false,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: _progressData.length,
                          itemBuilder: (context, index) {
                            final progress = _progressData[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ViewProgressPhotosWidget(),
                                  ),
                                );
                              },
                              child: Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Set background color to white
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 40,
                                            color: Theme.of(context).shadowColor,
                                            offset: Offset(
                                              0,
                                              10,
                                            ),
                                          )
                                        ],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(24),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Date: ${progress['date'] ?? 'N/A'}',
                                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                        color: Theme.of(context).primaryColor,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                                Align(
                                                  alignment: AlignmentDirectional(-1, 1),
                                                  child: Text(
                                                    'Weight: ${progress['weight'] ?? 'N/A'} kg',
                                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment: AlignmentDirectional(1, 0),
                                                child: Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.secondaryContainer,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: progress['pic'] != null
                                                        ? Image.network(
                                                            progress['pic'],
                                                            width: 200,
                                                            height: 200,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Container(
                                                            color: Colors.grey[300],
                                                            child: Icon(
                                                              Icons.image,
                                                              size: 50,
                                                              color: Colors.grey[600],
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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