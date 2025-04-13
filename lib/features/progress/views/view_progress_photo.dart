import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heronfit/features/progress/views/compare_progress_photo.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'compare_progress_photo.dart';

class ViewProgressPhotosWidget extends StatefulWidget {
  const ViewProgressPhotosWidget({super.key});

  static String routeName = 'ViewProgressPhotos';
  static String routePath = '/viewProgressPhotos';

  @override
  State<ViewProgressPhotosWidget> createState() =>
      _ViewProgressPhotosWidgetState();
}

class _ViewProgressPhotosWidgetState extends State<ViewProgressPhotosWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final supabaseClient = Supabase.instance.client;

  List<Map<String, dynamic>> _progressData = []; // Store fetched data
  bool _isLoading = true;
  int _selectedPhotoIndex = 0;

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
          const SnackBar(
            content: Text('You must be logged in to view progress data!'),
          ),
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
        _progressData = List<Map<String, dynamic>>.from(
          response as List<dynamic>,
        );
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
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
          child:
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _progressData.isEmpty
                  ? Center(
                    child: Text(
                      'No progress photos found',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  )
                  : Padding(
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 400,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child:
                                      _progressData.isNotEmpty
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              _progressData[_selectedPhotoIndex]['pic'] ??
                                                  '',
                                              width: double.infinity,
                                              height: 400,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Image.asset(
                                                    'assets/images/error_image.png',
                                                    width: double.infinity,
                                                    height: 400,
                                                    fit: BoxFit.cover,
                                                  ),
                                            ),
                                          )
                                          : Center(
                                            child: Text('No image available'),
                                          ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.check_box_outline_blank,
                                        color: Theme.of(context).primaryColor,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const ViewProgressPhotosWidget(),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.menu_book,
                                        color: Theme.of(context).primaryColor,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const CompareProgressPhotosWidget(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        _progressData.isNotEmpty
                                            ? '${_progressData[_selectedPhotoIndex]['weight']}kg'
                                            : 'No weight data',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelLarge?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        _progressData.isNotEmpty
                                            ? _formatDate(
                                              _progressData[_selectedPhotoIndex]['date'],
                                            )
                                            : 'No date data',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall?.copyWith(
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    primary: false,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _progressData.length,
                                    separatorBuilder:
                                        (_, __) => SizedBox(width: 7),
                                    itemBuilder: (context, index) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border:
                                                    _selectedPhotoIndex == index
                                                        ? Border.all(
                                                          color:
                                                              Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                          width: 3,
                                                        )
                                                        : null,
                                              ),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () {
                                                  setState(() {
                                                    _selectedPhotoIndex = index;
                                                  });
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    _progressData[index]['pic'] ??
                                                        '',
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Container(
                                                          color: Colors.grey,
                                                          child: Icon(
                                                            Icons.error,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
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

  // Helper function to format date string from database
  String _formatDate(dynamic date) {
    if (date == null) return 'No date';

    try {
      if (date is String) {
        final DateTime parsedDate = DateTime.parse(date);
        return '${_getMonthAbbreviation(parsedDate.month)} ${parsedDate.day} ${parsedDate.year}';
      } else if (date is DateTime) {
        return '${_getMonthAbbreviation(date.month)} ${date.day} ${date.year}';
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    return months[month - 1];
  }
}
