import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/domain/services/safe_url_validator.dart';

void main() {
  group('SafeUrlValidator', () {
    test('allows valid https, mailto, tel, and geo URIs for local ads', () {
      expect(
        SafeUrlValidator.parseSafeAdUri('https://wa.me/5493835123456'),
        isNotNull,
      );
      expect(
        SafeUrlValidator.parseSafeAdUri(
          'https://maps.google.com/?q=Andalgala+Catamarca',
        ),
        isNotNull,
      );
      expect(
        SafeUrlValidator.parseSafeAdUri('mailto:ventas@almacenelsol.com.ar'),
        isNotNull,
      );
      expect(SafeUrlValidator.parseSafeAdUri('tel:+5493835123456'), isNotNull);
      expect(SafeUrlValidator.parseSafeAdUri('geo:-27.581,-66.316'), isNotNull);
    });

    test('blocks dangerous schemes, cleartext http, and phishing patterns', () {
      const blockedUrls = <String>[
        '',
        '   ',
        'http://wa.me/5493835123456',
        'javascript:alert(1)',
        'JAVASCRIPT:window.location="https://evil.test"',
        'data:text/html,<script>alert(1)</script>',
        'vbscript:msgbox(1)',
        'file:///etc/passwd',
        'intent://scan/#Intent;scheme=zxing;end',
        'https://user:pass@wa.me/5493835123456',
        'https://localhost/admin',
        'https://127.0.0.1/callback',
        'https://192.168.0.1/login',
        'https://intranet.local/offer',
        'https://wa.me/549 3835',
        'mailto:not-an-email',
        'tel:abc',
      ];

      for (final url in blockedUrls) {
        expect(
          SafeUrlValidator.parseSafeAdUri(url),
          isNull,
          reason: 'Expected SafeUrlValidator to reject "$url"',
        );
      }
    });

    test('isSafeHttpsImageUrl strictly allows public HTTPS URLs only', () {
      expect(
        SafeUrlValidator.isSafeHttpsImageUrl(
          'https://jblsngzlpstojzwsdchb.supabase.co/storage/v1/object/public/ads-media/banner.png',
        ),
        isTrue,
      );
      expect(
        SafeUrlValidator.isSafeHttpsImageUrl('http://example.com/banner.png'),
        isFalse,
      );
      expect(
        SafeUrlValidator.isSafeHttpsImageUrl('mailto:info@example.com'),
        isFalse,
      );
      expect(
        SafeUrlValidator.isSafeHttpsImageUrl('javascript:alert(1)'),
        isFalse,
      );
    });
  });
}
