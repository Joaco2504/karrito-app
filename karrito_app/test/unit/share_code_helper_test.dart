import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/domain/services/share_code_helper.dart';

void main() {
  group('ShareCodeHelper', () {
    test('normalizes spaces, dashes, and lowercase into 6-char code', () {
      expect(ShareCodeHelper.normalizeAndValidate('k7m4p9'), 'K7M4P9');
      expect(ShareCodeHelper.normalizeAndValidate('  k7m-4p9  '), 'K7M4P9');
      expect(ShareCodeHelper.normalizeAndValidate('ab 12 cd'), 'AB12CD');
    });

    test('rejects invalid length or symbols', () {
      expect(ShareCodeHelper.normalizeAndValidate(''), isNull);
      expect(ShareCodeHelper.normalizeAndValidate('ABC12'), isNull);
      expect(ShareCodeHelper.normalizeAndValidate('ABC1234'), isNull);
      expect(ShareCodeHelper.normalizeAndValidate('AB_123'), isNull);
      expect(ShareCodeHelper.normalizeAndValidate('AB!123'), isNull);
    });

    test('buildJoinUri emits canonical karrito://join/<CODE> payload', () {
      expect(ShareCodeHelper.buildJoinUri('k7m-4p9'), 'karrito://join/K7M4P9');
      expect(ShareCodeHelper.buildJoinUri('AB12CD'), 'karrito://join/AB12CD');
    });

    test('extractCodeFromQrOrText handles raw codes and QR deep-links', () {
      expect(ShareCodeHelper.extractCodeFromQrOrText('K7M4P9'), 'K7M4P9');
      expect(ShareCodeHelper.extractCodeFromQrOrText(' k7m-4p9 '), 'K7M4P9');
      expect(
        ShareCodeHelper.extractCodeFromQrOrText('karrito://join/K7M4P9'),
        'K7M4P9',
      );
      expect(
        ShareCodeHelper.extractCodeFromQrOrText('KARRITO://JOIN/ab12cd/'),
        'AB12CD',
      );
      expect(
        ShareCodeHelper.extractCodeFromQrOrText(
          'https://karrito.app/join/M9N8P7',
        ),
        'M9N8P7',
      );
      expect(
        ShareCodeHelper.extractCodeFromQrOrText(
          'https://karrito.app/share?code=Q2W3E4',
        ),
        'Q2W3E4',
      );
    });

    test('extractCodeFromQrOrText rejects unrelated QR payloads', () {
      expect(ShareCodeHelper.extractCodeFromQrOrText(''), isNull);
      expect(
        ShareCodeHelper.extractCodeFromQrOrText('https://google.com'),
        isNull,
      );
      expect(
        ShareCodeHelper.extractCodeFromQrOrText('karrito://join/123'),
        isNull,
      );
      expect(
        ShareCodeHelper.extractCodeFromQrOrText('WIFI:S:MiRed;P:clave;;'),
        isNull,
      );
    });

    test('generateCode produces 6 valid uppercase alphanumeric characters', () {
      for (var i = 0; i < 20; i++) {
        final code = ShareCodeHelper.generateCode();
        expect(code, hasLength(6));
        expect(ShareCodeHelper.normalizeAndValidate(code), code);
      }
    });
  });
}
