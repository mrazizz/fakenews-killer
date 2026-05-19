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
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),        // bright blue
          secondary: Color(0xFF93C5FD),      // light blue
          surface: Color(0xFF0A1628),        // dark navy
          background: Color(0xFF000816),     // near-black midnight
          onPrimary: Colors.white,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF000816),
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
          bodyMedium: GoogleFonts.inter(color: const Color(0xFF93C5FD)),
          bodySmall: GoogleFonts.inter(color: const Color(0xFF93C5FD)),
          labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
          labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: const Color(0xFF93C5FD)),
          labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: const Color(0xFF93C5FD)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF000816),
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
