import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding_auth_screen.dart';
import 'theme/app_theme.dart';

class WebDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Yalnızca dikey yön — mobil uygulama için standart
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Durum çubuğunu saydam yap
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SesYolundaEglenceApp());
}

/// "Ses Yolunda Eğlence" — Oyunla Artikülasyon Terapisine Destek Sistemi
///
/// Temel kaynak: "Heceden Hikayeye Konuşma Sesi Bozuklukları Terapi
/// Alıştırma Kitabı" (Bengisu ve ark.)
///
/// Proje: İstinye Üniversitesi Yazılım Mühendisliği Bitirme Projesi
class SesYolundaEglenceApp extends StatelessWidget {
  const SesYolundaEglenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ses Yolunda Eğlence',
      debugShowCheckedModeBanner: false,
      scrollBehavior: WebDragScrollBehavior(),
      theme: AppTheme.theme,
      home: const OnboardingAuthScreen(),
    );
  }
}
