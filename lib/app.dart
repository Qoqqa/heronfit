import 'package:flutter/material.dart';
import 'views/home/home_screen.dart';  // Import HomeScreen

class HeronFitApp extends StatelessWidget {
  const HeronFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeronFit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),  // Start the app at HomeScreen
    );
  }
}
