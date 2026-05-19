import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const FakeNewsKillerApp());
}

class FakeNewsKillerApp extends StatelessWidget {
  const FakeNewsKillerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FakeNews Killer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
          displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
          displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
          headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
          headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
          headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
          titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
          titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: Colors.white),
          titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: Colors.white),
          bodyLarge: GoogleFonts.inter(color: Colors.white),
          bodyMedium: GoogleFonts.inter(color: Colors.white),
          bodySmall: GoogleFonts.inter(color: Colors.white),
          labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
          labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white),
          labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0A0A0F),
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
