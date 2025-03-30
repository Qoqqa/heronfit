import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'compare_progress_photo.dart';

// Initialize Supabase Client
final supabaseClient = Supabase.instance.client;

class ProgressPhotosListWidget extends StatefulWidget {
  const ProgressPhotosListWidget({super.key});

  static String routeName = 'ProgressPhotosList';
  static String routePath = '/progressPhotosList';

  @override
  State<ProgressPhotosListWidget> createState() =>
      _ProgressPhotosListWidgetState();
}

class _ProgressPhotosListWidgetState extends State<ProgressPhotosListWidget> {
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

      if (response == null || response.isEmpty) {
        throw Exception('Failed to fetch data: No data returned.');
      }

      setState(() {
        _progressData = List<Map<String, dynamic>>.from(response);
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
            onPressed: () async {
              // Navigate to the previous screen
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Progress Photos',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  letterSpacing: 0.0,
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
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          primary: false,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: _progressData.length,
                          itemBuilder: (context, index) {
                            final progress = _progressData[index];
                            return Card(
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
                                      color: Colors.white,
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