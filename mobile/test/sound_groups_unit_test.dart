import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/sound_groups_data.dart';
import 'package:mobile/utils/word_pictogram_helper.dart';

void main() {
  group('🎓 Bitirme Projesi Klinik Veri & Model Doğrulama Testleri', () {
    test('20 Klinik Ses Aşaması Eksiksiz Yüklenmeli', () {
      expect(kBookStages.length, equals(20), reason: 'Kitapta tam 20 klinik ses bulunmalıdır');
      
      final expectedPhonemes = [
        '/p/', '/b/', '/t/', '/d/', '/k/', '/g/',
        '/f/', '/v/', '/s/', '/z/', '/ş/', '/j/', '/h/',
        '/ç/', '/c/',
        '/m/', '/n/',
        '/l/', '/r/',
        '/y/'
      ];

      for (int i = 0; i < 20; i++) {
        expect(kBookStages[i].phoneme, equals(expectedPhonemes[i]));
      }
    });

    test('Her Aşama Tam Olarak 32 Standart Heceden Oluşmalı', () {
      for (final stage in kBookStages) {
        expect(
          stage.content.syllables.length,
          equals(32),
          reason: '${stage.phoneme} aşaması tam 32 standart hece içermelidir (8 CV, 8 VC, 8 VCV, 8 CVC)',
        );
      }
    });

    test('Tüm Aşamalarda Klinik Terapi Hikayesi Dolu ve Anlamlı Olmalı', () {
      for (final stage in kBookStages) {
        expect(stage.content.storyTitle.isNotEmpty, isTrue);
        expect(stage.content.storyContent.length, greaterThan(150),
            reason: '${stage.phoneme} hikayesi en az 150 karakterlik tam klinik hikaye olmalıdır');
      }
    });

    test('Pikogram Sözlüğü ve Emoji Temizliği Doğrulaması', () {
      final sampleWords = [
        'papatya', 'pasta', 'balık', 'tavşan', 'kedi',
        'köpek', 'gözlük', 'güneş', 'fare', 'vapur',
        'saat', 'zürafa', 'şapka', 'havuç', 'çiçek',
        'ceviz', 'maymun', 'nar', 'limon', 'radyo', 'yıldız'
      ];

      for (final word in sampleWords) {
        final emoji = WordPictogramHelper.getPictogram(word);
        expect(emoji.isNotEmpty, isTrue, reason: '$word için geçerli bir emoji bulunmalıdır');
        // Unicode combining dot karakteri içermemeli
        expect(emoji.contains('\u0307'), isFalse);
      }
    });
  });
}
