import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('Ana ekran duman testi', (WidgetTester tester) async {
    // Uygulamayı başlat ve bir kare oluştur.
    await tester.pumpWidget(const SesYolundaEglenceApp());

    // Ana ekranın yüklendiğini doğrula.
    expect(find.text('🎵 Ses Yolunda Eğlence'), findsNothing); // AppBar içinde
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
