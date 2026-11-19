/// Configuración pública de Supabase para la app cliente de Karrito.
///
/// Solo expone la URL del proyecto y la clave pública `anon`.
/// Las claves privilegiadas (`service_role`, `GEMINI_API_KEY`) viven
/// únicamente en las Edge Functions de Supabase.
abstract final class SupabaseConfig {
  static const String supabaseUrl = 'https://jblsngzlpstojzwsdchb.supabase.co';

  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpibHNuZ3pscHN0b2p6d3NkY2hiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ4NDM2MjIsImV4cCI6MjExMDQxOTYyMn0.'
      '5ZjeElsUz12OiNRD6C2p0zOQKUMiYDTBAcxWwg5mVmc';

  static const String schema = 'karrito';
}
