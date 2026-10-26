import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';

/// Entry point aplikasi L'Essence Recipes.
/// Menggunakan tema coklat-krem-hitam ala restoran premium dengan Material 3.
void main() {
  runApp(const LessenceApp());
}

class LessenceApp extends StatelessWidget {
  const LessenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna utama: coklat hangat (#C96A1B)
    const Color primaryColor = Color(0xFFC96A1B);
    // Warna latar krem (#FBF8F3)
    const Color backgroundColor = Color(0xFFFBF8F3);
    // Warna gelap (#1C1C1C)
    const Color darkColor = Color(0xFF1C1C1C);

    return MaterialApp(
      title: "L'Essence Recipes",
      debugShowCheckedModeBanner: false,
      // Tema Material 3 dengan Google Fonts Poppins
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          surface: backgroundColor,
          onSurface: darkColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        // Menggunakan Google Fonts Poppins untuk seluruh teks
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().textTheme,
        ),
        // AppBar styling
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: darkColor,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),
        // ElevatedButton styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // CircularProgressIndicator color
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primaryColor,
        ),
      ),
      home: const HomePage(),
    );
  }
}
