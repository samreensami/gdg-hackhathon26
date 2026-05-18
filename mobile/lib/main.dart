import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const InsightFlowApp(),
    ),
  );
}

class AppState extends ChangeNotifier {
  String language = 'en';

  void toggleLanguage() {
    language = (language == 'en') ? 'ur' : 'en';
    notifyListeners();
  }

  bool get isUrdu => language == 'ur';
}

class InsightFlowApp extends StatelessWidget {
  const InsightFlowApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsightFlow AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: 
          const Color(0xFF020B18),
        primaryColor: const Color(0xFF00D4FF),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
