import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/pages/onBoarding/onboarding_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp())); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travelin',
      theme: ThemeData(fontFamily: 'Helvetica'),
      debugShowCheckedModeBanner: false,
      home: const OnboardingPage(),
    );
  }
}
