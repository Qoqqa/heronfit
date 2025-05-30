import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solar_icons/solar_icons.dart';
import '../widgets/gym_availability_card.dart';
import '../widgets/upcoming_session_card.dart';
import '../widgets/recent_activity_card.dart';
import 'package:heronfit/features/booking/views/booking_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/notifications/controllers/notifications_controller.dart'
    as controller;
import 'package:badges/badges.dart' as badges;

class HomeWidget extends ConsumerStatefulWidget {
  const HomeWidget({super.key});

  static String routePath = '/home';

  @override
  ConsumerState<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends ConsumerState<HomeWidget> {
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

        if (mounted) {
          setState(() {
            userName = response['first_name'] ?? 'User';
            userEmail = user.email;
          });
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        if (mounted) {
          setState(() {
            userName = 'User';
            userEmail = user.email;
          });
        }
      }
    }
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('Error logging out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final notificationsAsyncValue = ref.watch(controller.notificationsProvider);

    final unreadCount = notificationsAsyncValue.when(
      data: (notifications) => notifications.where((n) => !n.isRead).length,
      loading: () => 0,
      error: (err, stack) => 0,
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            top: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 24,
                        left: 8,
                        right: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome,',
                                  textAlign: TextAlign.start,
                                  style: textTheme.titleSmall?.copyWith(
                                    color: colorScheme.onBackground.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getDisplayName(userName),
                                  textAlign: TextAlign.start,
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          badges.Badge(
                            showBadge: unreadCount > 0,
                            badgeContent: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            badgeStyle: badges.BadgeStyle(
                              badgeColor: colorScheme.error,
                              padding: const EdgeInsets.all(5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            position: badges.BadgePosition.topEnd(
                              top: -5,
                              end: -5,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.background,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.05),
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  SolarIconsBold.bell,
                                  color: colorScheme.primary,
                                  size: 26,
                                ),
                                onPressed: () {
                                  context.push(AppRoutes.notifications);
                                },
                                tooltip: 'Notifications',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const GymAvailabilityCard(),
                    const SizedBox(height: 16),
                    const UpcomingSessionCard(),
                    const SizedBox(height: 16),
                    const RecentActivityCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDisplayName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'User';
    }

    final nameParts = fullName.trim().split(' ');
    return nameParts.first;
  }
}
