/// Configuración centralizada de monetización (Google AdMob + RevenueCat) y
/// límites de compresión multimedia para Karrito Android.
abstract final class MonetizationConfig {
  // ---------------------------------------------------------------------------
  // Google AdMob (IDs de producción de Karrito Android)
  // ---------------------------------------------------------------------------

  /// App ID de Google AdMob (sincronizado con AndroidManifest.xml).
  static const String admobAppIdAndroid =
      'ca-app-pub-3394998686748411~2905797025';

  /// Bloque `karrito_banner_lista` (banner adaptativo inferior).
  static const String admobBannerUnitIdAndroid =
      'ca-app-pub-3394998686748411/2518784212';

  /// Bloque `karrito_intersticial_lista` (intersticial de respaldo).
  static const String admobInterstitialUnitIdAndroid =
      'ca-app-pub-3394998686748411/3511255506';

  // ---------------------------------------------------------------------------
  // RevenueCat (proyecto Karrito · solo planes mensuales, sin plan anual)
  // ---------------------------------------------------------------------------

  /// Clave pública SDK de Google Play (`goog_...`) del proyecto `Karrito` en RevenueCat.
  static const String revenueCatGoogleApiKey =
      'goog_tRuWXSFayIybVuZOScsjAbrtZXH';

  /// Devuelve `true` solo cuando se cargó una clave real de RevenueCat.
  static bool get isRevenueCatConfigured {
    final trimmed = revenueCatGoogleApiKey.trim();
    return trimmed.isNotEmpty &&
        trimmed != 'REVENUECAT_GOOGLE_API_KEY' &&
        !trimmed.toUpperCase().contains('TODO');
  }

  /// Offering principal en RevenueCat.
  static const String revenueCatOfferingId = 'default';

  /// Entitlements fijos definidos en `.agents/memory.md` y `revenuecat-webhook`.
  static const String entitlementBasic = 'basic_access';
  static const String entitlementPro = 'pro_access';

  /// Paquetes mensuales dentro del offering `default` (sin opción anual).
  static const String packageBasicMonthly = 'basic_monthly';
  static const String packageProMonthly = 'pro_monthly';

  /// Base plans mensuales configurados en Google Play Console / RevenueCat.
  static const String basePlanBasicMonthly = 'basic-monthly';
  static const String basePlanProMonthly = 'pro-monthly';

  /// IDs de productos en Google Play / RevenueCat.
  static const String productBasicId = 'karrito_basic_2usd';
  static const String productProId = 'karrito_pro_3usd';

  // ---------------------------------------------------------------------------
  // Límites de compresión multimedia (`karrito-media-guard`)
  // ---------------------------------------------------------------------------

  /// Duración máxima de dictado por voz antes de cortar/rechazar en cliente.
  static const int maxVoiceDurationSeconds = 60;

  /// Peso máximo del archivo M4A/AAC (500 KB) antes de enviar a `procesar-lista`.
  static const int maxVoiceBytes = 500 * 1024;

  /// Bitrate de grabación de voz en AAC-LC (48 kbps).
  static const int voiceBitRateBps = 48000;

  /// Frecuencia de muestreo de voz (16 kHz mono, óptimo para reconocimiento).
  static const int voiceSampleRateHz = 16000;

  /// Lado mayor máximo al comprimir fotos o capturas antes de enviar a IA.
  static const int maxImageDimensionPx = 1024;

  /// Calidad JPEG (75%) exigida por `karrito-media-guard`.
  static const int imageJpegQuality = 75;
}
