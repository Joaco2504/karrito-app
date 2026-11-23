/// Strict anti-phishing & scheme validation for external URLs opened by Karrito
/// (local merchant banners, interstitial CTAs, and remote artwork URLs).
class SafeUrlValidator {
  SafeUrlValidator._();

  static const int _maxUrlLength = 2048;
  static const Set<String> _allowedActionSchemes = <String>{
    'https',
    'mailto',
    'tel',
    'geo',
  };
  static final RegExp _controlOrSpaceRegex = RegExp(r'[\u0000-\u001F\u007F\s]');
  static final RegExp _ipv4HostRegex = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$');
  static final RegExp _telPathRegex = RegExp(r'^[+\d][\d\s\-()]{3,24}$');

  /// Validates an external ad destination URL before opening with `url_launcher`.
  /// Allows only `https://` (public domain, no credentials), `mailto:`, `tel:`,
  /// and `geo:`. Returns `null` for `http:`, `javascript:`, `data:`, `intent:`,
  /// `file:`, or suspicious phishing URIs.
  static Uri? parseSafeAdUri(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty || trimmed.length > _maxUrlLength) return null;

    final lower = trimmed.toLowerCase();
    // Allow spaces only in `tel:` numbers; block spaces/control chars elsewhere.
    final isTel = lower.startsWith('tel:');
    if (!isTel && _controlOrSpaceRegex.hasMatch(trimmed)) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) return null;

    final scheme = uri.scheme.toLowerCase();
    if (!_allowedActionSchemes.contains(scheme)) {
      return null;
    }

    switch (scheme) {
      case 'https':
        if (uri.userInfo.isNotEmpty) return null;
        final host = uri.host.trim().toLowerCase();
        if (!_isValidPublicHost(host)) return null;
        return uri;
      case 'mailto':
        final address = uri.path.trim();
        final atIdx = address.indexOf('@');
        if (atIdx <= 0 || atIdx >= address.length - 3) return null;
        final domain = address.substring(atIdx + 1);
        if (!domain.contains('.')) return null;
        return uri;
      case 'tel':
        final phone = uri.path.trim();
        if (!_telPathRegex.hasMatch(phone)) return null;
        return uri;
      case 'geo':
        final path = uri.path.trim();
        if (path.isEmpty && !uri.hasQuery) return null;
        return uri;
      default:
        return null;
    }
  }

  /// Validates remote ad image URLs (`banner_url`, `interstitial_url`): strictly
  /// HTTPS on a public domain with no embedded credentials.
  static bool isSafeHttpsImageUrl(String? raw) {
    final uri = parseSafeAdUri(raw);
    return uri != null && uri.scheme.toLowerCase() == 'https';
  }

  static bool _isValidPublicHost(String host) {
    if (host.isEmpty || !host.contains('.')) return false;
    if (host == 'localhost' ||
        host.endsWith('.local') ||
        host.endsWith('.internal')) {
      return false;
    }
    if (_ipv4HostRegex.hasMatch(host) || host.startsWith('[')) {
      return false;
    }
    return true;
  }
}
