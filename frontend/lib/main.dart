import 'package:flutter/material.dart';
import 'package:frontend/features/home/pages/home_page.dart';
import 'package:frontend/features/overview/pages/overview_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),

      home: const OverviewPage(),
    );
  }
}
