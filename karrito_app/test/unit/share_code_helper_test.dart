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

    test('generateCode produces 6 valid uppercase alphanumeric characters', () {
      for (var i = 0; i < 20; i++) {
        final code = ShareCodeHelper.generateCode();
        expect(code, hasLength(6));
        expect(ShareCodeHelper.normalizeAndValidate(code), code);
      }
    });
  });
}
