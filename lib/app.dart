import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/core/theme.dart'; // Corrected import path
import 'package:heronfit/core/router/app_router.dart'; // Import the router provider

class HeronFitApp extends ConsumerWidget {
  const HeronFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider); // Get the router instance

    return MaterialApp.router(
      title: 'HeronFit',
      theme: HeronFitTheme.lightTheme,
      // darkTheme: HeronFitTheme.darkTheme, // Optional: if you have a dark theme
      themeMode: ThemeMode.light, // Or ThemeMode.system / ThemeMode.dark
      routerConfig: goRouter, // Use routerConfig
      debugShowCheckedModeBanner: false,
    );
  }
}
