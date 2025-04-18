import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: HeronFitTheme.primary,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: HeronFitTheme.primary,
                                      width: 3,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType.fade,
                                            child: Scaffold(
                                              appBar: AppBar(),
                                              body: Center(
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      'https://images.unsplash.com/photo-1531123414780-f74242c2b052?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NDV8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                                                  fit: BoxFit.contain,
                                                  placeholder:
                                                      (context, url) => Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  HeronFitTheme
                                                                      .primary,
                                                            ),
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(
                                                            SolarIconsBold.user,
                                                            color:
                                                                HeronFitTheme
                                                                    .primary,
                                                          ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              'https://images.unsplash.com/photo-1531123414780-f74242c2b052?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NDV8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) => Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color:
                                                          HeronFitTheme.primary,
                                                    ),
                                              ),
                                          errorWidget:
                                              (context, url, error) => Icon(
                                                SolarIconsBold.user,
                                                color: HeronFitTheme.primary,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'John Doe',
                                        style: textTheme.titleLarge?.copyWith(
                                          color: HeronFitTheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Goal | ',
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: colorScheme.onSurface
                                                        .withAlpha(
                                                          ((0.7 * 255).round()),
                                                        ),
                                                  ),
                                            ),
                                            TextSpan(
                                              text: 'Lose Weight',
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                          style: textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.push(AppRoutes.profileEdit);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                backgroundColor: colorScheme.secondary,
                                foregroundColor: Colors.white,
                                textStyle: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text('Edit'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoCard(context, '180 cm', 'Height'),
                            _buildInfoCard(context, '70 kg', 'Weight'),
                            _buildInfoCard(context, '25 yo', 'Age'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _buildAccountSection(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _buildNotificationSection(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _buildOtherSection(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await Supabase.instance.client.auth.signOut();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Logged out successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              context.go(AppRoutes.onboarding);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error logging out: $e'),
                                  backgroundColor: HeronFitTheme.error,
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            SolarIconsOutline.logout,
                            size: 24.0,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Logout',
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 48),
                            elevation: 2,
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
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String value, String label) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: colorScheme.surface,
        elevation: 4,
        shadowColor: Theme.of(
          context,
        ).shadowColor.withAlpha(((0.5 * 255).round())),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: HeronFitTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withAlpha(((0.7 * 255).round())),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return _buildSection(context, 'Account', [
      _buildSectionItem(context, SolarIconsOutline.user, 'Edit Profile', () {
        context.push(AppRoutes.profileEdit);
      }),
      _buildSectionItem(context, SolarIconsOutline.notebook, 'My Bookings', () {
        context.push(AppRoutes.bookings);
      }),
      _buildSectionItem(
        context,
        SolarIconsOutline.history,
        'Workout History',
        () {
          context.push(AppRoutes.profileHistory);
        },
      ),
    ]);
  }

  Widget _buildNotificationSection(BuildContext context) {
    return _buildSection(context, 'Notification', [
      _buildSectionItem(
        context,
        SolarIconsOutline.bell,
        'Pop-up Notification',
        () {
          // Removed print statement
        },
      ),
    ]);
  }

  Widget _buildOtherSection(BuildContext context) {
    return _buildSection(context, 'Other', [
      _buildSectionItem(context, SolarIconsOutline.letter, 'Contact Us', () {
        context.push(AppRoutes.profileContact);
      }),
      _buildSectionItem(
        context,
        SolarIconsOutline.shieldUser,
        'Privacy Policy',
        () {
          context.push(AppRoutes.profilePrivacy);
        },
      ),
      _buildSectionItem(
        context,
        SolarIconsOutline.documentText,
        'Terms Of Use',
        () {
          context.push(AppRoutes.profileTerms);
        },
      ),
    ]);
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Theme.of(
              context,
            ).shadowColor.withAlpha(((0.15 * 255).round())),
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) => items[index],
              separatorBuilder:
                  (context, index) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: colorScheme.outline.withAlpha(((0.3 * 255).round())),
                    indent: 40,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      splashColor: HeronFitTheme.primary.withAlpha(((0.1 * 255).round())),
      focusColor: HeronFitTheme.primary.withAlpha(((0.1 * 255).round())),
      hoverColor: HeronFitTheme.primary.withAlpha(((0.05 * 255).round())),
      highlightColor: HeronFitTheme.primary.withAlpha(((0.1 * 255).round())),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, color: HeronFitTheme.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: textTheme.bodyMedium)),
            Icon(
              SolarIconsOutline.altArrowRight,
              color: colorScheme.onSurface.withAlpha(((0.6 * 255).round())),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
