import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/views/login_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      // Redirect to login if no user is logged in
      return const LoginScreen();
    }

    // Allow access if user is logged in
    return child;
  }
}
