import 'package:flutter/material.dart';

/// Uygulamanın renk paleti ve metin stillerini merkezi olarak tanımlar.
/// Çocuk dostu: canlı renkler, yuvarlak köşeler, büyük metin boyutları.
class AppTheme {
  AppTheme._();

  // ── Ana renkler ────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4CAF50);      // yeşil (başarı)
  static const Color secondary = Color(0xFFFFC107);    // sarı (yıldız/ödül)
  static const Color accent = Color(0xFF2196F3);       // mavi (vurgu)
  static const Color background = Color(0xFFF5F9FF);   // açık mavi-beyaz
  static const Color surface = Color(0xFFFFFFFF);
  static const Color locked = Color(0xFFB0BEC5);       // kilitli seviye rengi
  static const Color starActive = Color(0xFFFFD700);   // altın yıldız
  static const Color starInactive = Color(0xFFE0E0E0); // boş yıldız

  // ── Tema nesnesi ────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: background,
        fontFamily: 'Nunito', // pubspec.yaml'a eklenirse otomatik aktifleşir
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
