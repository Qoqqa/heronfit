import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:heronfit/core/router/app_routes.dart'; // Import routes

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      try {
        // Fetch user details from the 'users' table
        final response =
            await Supabase.instance.client
                .from('users')
                .select('first_name')
                .eq('id', user.id)
                .single();

        setState(() {
          userName =
              response['first_name'] ??
              'User'; // Use the first_name from the table
          userEmail = user.email; // Use the email from the auth session
        });
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        setState(() {
          userName = 'User'; // Fallback if fetching fails
          userEmail = user.email;
        });
      }
    } else {
      // If no user is logged in, navigate to the login screen
      if (context.mounted) {
        context.go(AppRoutes.login); // Use context.go to replace stack
      }
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      context.go(AppRoutes.login); // Use context.go to replace stack
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            top: true,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: SingleChildScrollView(
                // Added SingleChildScrollView
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        0,
                        0,
                        0,
                        36,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(-1, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(-1, 0),
                                      child: Text(
                                        'Welcome,',
                                        textAlign: TextAlign.start,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onBackground,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(-1, 0),
                                      child: Text(
                                        userName ?? 'Loading...',
                                        textAlign: TextAlign.start,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  // Removed the boxShadow property to eliminate the shadow
                                  color:
                                      Theme.of(context)
                                          .colorScheme
                                          .background, // Optional: Add a background color if needed
                                  shape:
                                      BoxShape
                                          .circle, // Ensures the button remains circular
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.notifications,
                                    color: Theme.of(context).primaryColor,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    // Navigate to Notification screen
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.background,
                                      /*boxShadow: [
                                        BoxShadow(
                                          blurRadius: 40,
                                          color: Theme.of(context).shadowColor,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],*/
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                  0,
                                                  0,
                                                  0,
                                                  16,
                                                ),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () {
                                                // Navigate to Book A Session screen
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Gym Availability',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                        ),
                                                  ),
                                                  Icon(
                                                    Icons
                                                        .event_available_outlined,
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                    size: 24,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                  0,
                                                  0,
                                                  0,
                                                  8,
                                                ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional.fromSTEB(
                                                        0,
                                                        0,
                                                        8,
                                                        0,
                                                      ),
                                                  child: Icon(
                                                    Icons.date_range_outlined,
                                                    color:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onBackground,
                                                    size: 24,
                                                  ),
                                                ),
                                                Text(
                                                  'Monday, October 25',
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.labelMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                  0,
                                                  0,
                                                  0,
                                                  8,
                                                ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional.fromSTEB(
                                                        0,
                                                        0,
                                                        8,
                                                        0,
                                                      ),
                                                  child: Icon(
                                                    Icons.access_time_rounded,
                                                    color:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onBackground,
                                                    size: 24,
                                                  ),
                                                ),
                                                Text(
                                                  '10:00 AM - 11:00 AM',
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.labelMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                  0,
                                                  0,
                                                  0,
                                                  8,
                                                ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional.fromSTEB(
                                                        0,
                                                        0,
                                                        8,
                                                        0,
                                                      ),
                                                  child: Icon(
                                                    Icons.groups_outlined,
                                                    color:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onBackground,
                                                    size: 24,
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: '10',
                                                        style:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .labelMedium,
                                                      ),
                                                      TextSpan(
                                                        text: '/15 capacity',
                                                        style:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .labelMedium,
                                                      ),
                                                    ],
                                                    style:
                                                        Theme.of(
                                                          context,
                                                        ).textTheme.labelSmall,
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
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      /*boxShadow: [
                                        BoxShadow(
                                          blurRadius: 40,
                                          color: Theme.of(context).shadowColor,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],*/
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                  0,
                                                  0,
                                                  0,
                                                  16,
                                                ),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () {
                                                // Navigate to My Bookings screen
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Upcoming Session',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  Icon(
                                                    Icons.event_note_outlined,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                  0,
                                                  0,
                                                  0,
                                                  8,
                                                ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional.fromSTEB(
                                                        0,
                                                        0,
                                                        8,
                                                        0,
                                                      ),
                                                  child: Icon(
                                                    Icons.date_range_outlined,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                                Text(
                                                  'No Booked Sessions!',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.background,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 0,
                                          color: Theme.of(context).shadowColor,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                  0,
                                                  0,
                                                  0,
                                                  16,
                                                ),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () {
                                                // Navigate to Workout History screen
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Recent Activity',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                        ),
                                                  ),
                                                  Icon(
                                                    Icons.event_repeat_outlined,
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                    size: 24,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                  0,
                                                  0,
                                                  0,
                                                  8,
                                                ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional.fromSTEB(
                                                        0,
                                                        0,
                                                        8,
                                                        0,
                                                      ),
                                                  child: Icon(
                                                    Icons.date_range_outlined,
                                                    color:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onBackground,
                                                    size: 24,
                                                  ),
                                                ),
                                                Text(
                                                  'Last Workout: Yesterday, 45 mins',
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.labelMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                  0,
                                                  0,
                                                  0,
                                                  8,
                                                ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional.fromSTEB(
                                                        0,
                                                        0,
                                                        8,
                                                        0,
                                                      ),
                                                  child: Icon(
                                                    Icons.update_outlined,
                                                    color:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onBackground,
                                                    size: 24,
                                                  ),
                                                ),
                                                Text(
                                                  'Workouts This Week: 3',
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.labelMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                  0,
                                                  0,
                                                  0,
                                                  8,
                                                ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional.fromSTEB(
                                                        0,
                                                        0,
                                                        8,
                                                        0,
                                                      ),
                                                  child: Icon(
                                                    Icons.timer_outlined,
                                                    color:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onBackground,
                                                    size: 24,
                                                  ),
                                                ),
                                                Text(
                                                  'Total Time This Week: 2.5 hours',
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.labelMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                              .map(
                                (widget) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: widget,
                                ),
                              )
                              .toList(),
                    ),
                    SizedBox(
                      height: 20,
                    ), // Added SizedBox to provide extra space
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
