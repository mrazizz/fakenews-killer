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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFFFFF),
          secondary: Color(0xFF8E8E8E),
          surface: Color(0xFF1C1C1C),
          onPrimary: Color(0xFF000000),
          onSurface: Color(0xFFFFFFFF),
        ),
        cardColor: const Color(0xFF1C1C1C),
        dividerColor: const Color(0xFF2A2A2A),
        useMaterial3: true,
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
          bodyMedium: GoogleFonts.inter(color: const Color(0xFF8E8E8E)),
          bodySmall: GoogleFonts.inter(color: const Color(0xFF8E8E8E)),
          labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
          labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: const Color(0xFF8E8E8E)),
          labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: const Color(0xFF8E8E8E)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF000000),
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
