import 'dart:convert';
import 'package:flutter/material.dart';

class AppTheme {
  // Texas A&M University Brand Palette
  static const Color aggieMaroon = Color(0xFF500000);
  static const Color aggieMaroonLight = Color(0xFF731A1A);
  static const Color aggieMaroonDark = Color(0xFF380000);
  static const Color primaryContainer = Color(0xFFFFD8D6);
  static const Color onPrimaryContainer = Color(0xFF3E0003);

  // Aggie Brass / Sand Accent
  static const Color aggieBrass = Color(0xFF8F6A00);
  static const Color brassContainer = Color(0xFFFFE08B);

  // Surface and Neutrals (Warm Aggie White)
  static const Color surface = Color(0xFFFFF8F7);
  static const Color surfaceContainer = Color(0xFFF7EDED);
  static const Color surfaceContainerHigh = Color(0xFFF1E7E6);
  static const Color outline = Color(0xFF857372);
  static const Color outlineVariant = Color(0xFFD8C2C1);

  // Functional Status Colors
  static const Color statusGreen = Color(0xFF15803D);
  static const Color statusGreenBg = Color(0xFFDCFCE7);
  static const Color statusAmber = Color(0xFFD97706);
  static const Color statusAmberBg = Color(0xFFFEF3C7);
  static const Color statusRed = Color(0xFFDC2626);
  static const Color statusRedBg = Color(0xFFFEE2E2);

  // Light Theme Data
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: aggieMaroon,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: aggieBrass,
      onSecondary: Colors.white,
      secondaryContainer: brassContainer,
      onSecondaryContainer: const Color(0xFF2E2000),
      surface: surface,
      onSurface: const Color(0xFF231919),
      surfaceContainerHighest: surfaceContainerHigh,
      onSurfaceVariant: const Color(0xFF524343),
      outline: outline,
      outlineVariant: outlineVariant,
      error: statusRed,
      onError: Colors.white,
      errorContainer: statusRedBg,
      onErrorContainer: const Color(0xFF410002),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: aggieMaroon,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFECE4E3), width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainer,
        selectedColor: primaryContainer,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: aggieMaroon,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: aggieMaroon, width: 2),
        ),
      ),
    );
  }

  /// Helper to safely load avatar from either Network or Base64 data URI
  static ImageProvider getAvatarImage(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.startsWith('data:image')) {
      try {
        final base64String = avatarUrl.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } catch (_) {}
    }
    return NetworkImage(
      avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    );
  }
}

