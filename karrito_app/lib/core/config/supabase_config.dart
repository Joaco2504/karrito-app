/// Configuración pública de Supabase y OAuth cliente para Karrito.
///
/// Solo expone identificadores públicos (`url`, `anon`, Web Client ID OAuth).
/// Las claves secretas (`service_role`, `GEMINI_API_KEY`, client secret OAuth)
/// viven únicamente en Supabase.
abstract final class SupabaseConfig {
  static const String supabaseUrl = 'https://jblsngzlpstojzwsdchb.supabase.co';

  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpibHNuZ3pscHN0b2p6d3NkY2hiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ4NDM2MjIsImV4cCI6MjExMDQxOTYyMn0.'
      '5ZjeElsUz12OiNRD6C2p0zOQKUMiYDTBAcxWwg5mVmc';

  static const String schema = 'karrito';

  /// Web Client ID (`client_type: 3`) extraído de `android/app/google-services.json`.
  static const String googleWebClientId =
      '971712549329-74go0rk99uvi2rsenfvthls858t66q9d.apps.googleusercontent.com';
}
