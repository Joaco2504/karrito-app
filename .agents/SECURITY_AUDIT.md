# Auditoría de Seguridad, Anti-Phishing y Rendimiento — Karrito (Fase 5.4)

- **Fecha**: 23/11/2026
- **Alcance**: `karrito_app` (Flutter/Android), `karrito_admin` (Next.js 16), `supabase/` (PostgreSQL schema `karrito`, Storage bucket `ads-media`, Edge Functions `procesar-lista` y `revenuecat-webhook`) e historial completo de Git.
- **Objetivo**: Blindaje integral previo a la publicación en Google Play Store.

---

## 1. Historial de Git, secretos y `.gitignore`

### Lo revisado
- Búsqueda automatizada en todos los commits (`git log --all`) y en el árbol de archivos rastreados (`git ls-files`) buscando patrones de secretos: `sk_`, `AIza`, `service_role`, tokens JWT `eyJhbGci...`, `REVENUECAT_WEBHOOK_SECRET`, `.env.local`, `firebase-adminsdk`, `*.jks`, `*.keystore`, `*.p12`, `key.properties`.
- Inspección de `.gitignore` en la raíz del repositorio.

### Hallazgos
1. **0 secretos críticos filtrados en el historial de Git**:
   - `sk_` (RevenueCat Secret / Stripe / OpenAI): **0 coincidencias**.
   - JWT `service_role` de Supabase: **0 tokens JWT** en todo el historial (solo referencias de texto/documentación y código de servidor que lee `Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")` o `process.env.SUPABASE_SERVICE_ROLE_KEY`).
   - `REVENUECAT_WEBHOOK_SECRET`, `.env.local`, `*firebase-adminsdk*.json`, `*.jks`, `*.keystore`: **0 archivos filtrados**.
2. **Clave cliente Firebase Android en `karrito_app/android/app/google-services.json`** (`AIzaSyAc...`):
   - Es la clave de cliente Android estándar de Firebase (pública por diseño dentro de los APK para conectar FCM / Google Sign-In).
   - **Recomendación antes de Google Play**: En Google Cloud Console -> *APIs y servicios -> Credenciales*, restringir esa API key únicamente a la app Android `com.karrito.app` (con el SHA-1 de la firma de release de Play App Signing) y limitar las APIs habilitadas exclusivamente a Firebase Cloud Messaging / Installations.
3. **Patrones faltantes en `.gitignore` (bajo/medio)**:
   - No bloqueaba `*.jks`, `*.keystore`, `*.p12`, `*.pem`, `*.key`, `key.properties`, `**/key.properties` ni `supabase/.env`.

### Correcciones aplicadas
- Actualizado `.gitignore` para bloquear todos los formatos de keystores de firma Android, claves privadas y archivos de entorno de Supabase (`*.jks`, `*.keystore`, `*.p12`, `*.pem`, `*.key`, `key.properties`, `**/key.properties`, `supabase/.env`).

---

## 2. Base de datos Supabase (PostgreSQL schema `karrito`) y Storage (`ads-media`)

### Lo revisado
- Consulta directa en producción (`jblsngzlpstojzwsdchb`) sobre `pg_tables`, `pg_policies`, `pg_trigger` y `storage.buckets`.

### Hallazgos
1. **RLS activo en las 9 tablas de `karrito`**: confirmado `rowsecurity = true` en `admin_users`, `aisle_preferences`, `app_config`, `learned_items`, `list_items`, `list_members`, `local_ads`, `shopping_lists` y `users_profile`.
   - `trg_protect_user_fields` activo en `users_profile` impidiendo que usuarios autenticados alteren `plan_tier`, `daily_ai_count`, `last_ai_date` o `is_banned`.
   - Ninguna política permite leer ni modificar registros ajenos (`user_id = auth.uid()` / `owner_id = auth.uid()` / `is_list_member(list_id)`).
2. **Brecha en `karrito.shopping_lists` (Medio)**: `shopping_lists_update` habilita a miembros invitados (`is_list_member`) para sincronizar cambios colaborativos de título, pero faltaba un trigger que impidiera a un invitado alterar `owner_id`, `is_shared` o `share_code`.
3. **Bucket `ads-media` sin límites de tamaño ni MIME (Alto)**: en producción tenía `file_size_limit = null` y `allowed_mime_types = null` (permitía subir archivos arbitrarios grandes o tipos peligrosos como SVG/HTML si se usaban credenciales de escritura).

### Correcciones aplicadas y verificadas en producción
- Creada y aplicada en producción la migración `supabase/migrations/20261123180000_fase54_security_hardening.sql`:
  - `storage.buckets` (`id = 'ads-media'`): configurado **`file_size_limit = 2097152`** (2 MB) y **`allowed_mime_types = ARRAY['image/png', 'image/jpeg', 'image/webp']`**. Verificado mediante `SELECT` en producción.
  - Creado trigger `trg_protect_shopping_list_ownership` (`karrito.protect_shopping_list_ownership()`) en `karrito.shopping_lists` bloqueando con `42501` cualquier intento de un cliente no propietario de cambiar `owner_id`, `is_shared` o `share_code`.
  - Reafirmado `ENABLE ROW LEVEL SECURITY` en las 9 tablas.

---

## 3. Edge Functions (`procesar-lista` y `revenuecat-webhook`)

### Lo revisado
- Revisión completa de `supabase/functions/procesar-lista/index.ts` y `supabase/functions/revenuecat-webhook/index.ts`.

### Hallazgos
1. **CORS abierto (`*`) en `procesar-lista` (Medio)**: importaba `corsHeaders` genérico (`Access-Control-Allow-Origin: *`).
2. **Límites de entrada excesivos en `procesar-lista` (Medio)**: permitía `text` de hasta `8.000` caracteres y media base64 de hasta `14.000.000` caracteres (~10 MB), exponiendo la cuota de Gemini a payloads abusivos. Además, `is_recipe: true` no estaba bloqueado en servidor para usuarios no Pro.
3. **Comparación de secreto en `revenuecat-webhook` (Bajo)**: `constantTimeEquals` hacía retorno temprano si difería la longitud de bytes (`aBytes.length !== bBytes.length`), y no limitaba el tamaño del cuerpo JSON.

### Correcciones aplicadas y desplegadas en producción
- **`procesar-lista`** (redesplegada en `jblsngzlpstojzwsdchb`):
  - Eliminado el wildcard CORS `*`; reemplazado por `buildCorsHeaders(req)` con lista explícita de orígenes permitidos (`ALLOWED_ORIGINS` + orígenes oficiales), `Vary: Origin`, `X-Content-Type-Options: nosniff`, `Cache-Control: no-store` y rechazo `403` para orígenes web no autorizados.
  - Endurecidos los topes de entrada: `MAX_TEXT_LENGTH = 4_000`, `MAX_AUDIO_BASE64_LENGTH = 720_000` (~540 KB), `MAX_IMAGE_BASE64_LENGTH = 2_800_000` (~2 MB) y verificación previa de `Content-Length`.
  - Aplicado control de plan Pro (`pro_3usd`) en servidor también cuando `is_recipe === true`.
- **`revenuecat-webhook`** (redesplegada en `jblsngzlpstojzwsdchb`):
  - Mejorado `constantTimeEquals` con digestión `SHA-256` (`crypto.subtle.digest`) sobre ambos valores antes del XOR byte a byte, eliminando cualquier fuga temporal por longitud.
  - Agregado tope `MAX_WEBHOOK_BODY_BYTES = 65_536`, `X-Content-Type-Options: nosniff` y `Cache-Control: no-store`.
  - Confirmado que los precios/planes nunca se aceptan desde la app cliente: solo se resuelven a partir de entitlements/product IDs autenticados del webhook de RevenueCat o acciones del panel admin.

---

## 4. Panel web administrativo `karrito_admin` (Next.js 16)

### Lo revisado
- `next.config.ts`, `middleware.ts`, `lib/auth/admin.ts`, `app/auth/callback/route.ts`, `app/actions/admin-actions.ts`, `app/api/ads/upload/route.ts`, `lib/data/dashboard.ts`, `components/admin/*` y `npm audit`.

### Hallazgos
1. **Sin cabeceras HTTP de seguridad en `next.config.ts` (Medio)**.
2. **Validación de URLs y redirecciones (Alto — Anti-Phishing / Anti-Open Redirect)**:
   - `admin-actions.ts` aceptaba enlaces `http://` sin cifrar y no validaba origen del bucket `ads-media` ni bloqueaba credenciales embebidas (`https://user:pass@...`) o hosts locales/IP.
   - `/auth/callback` confiaba en el encabezado `x-forwarded-host` sin lista blanca y no saneaba el parámetro `next`.
   - `local-ads-section.tsx` renderizaba `<a href={ad.action_url}>` sin defensa en capa UI.
3. **Subida de archivos en `/api/ads/upload` (Medio)**:
   - Aceptaba `image/gif` y hasta `5 MB`, y confiaba solo en `file.type` sin verificar los *magic bytes* binarios del archivo.
4. **Vulnerabilidades y dependencias sin uso en `package.json` (Moderado)**:
   - `npm audit` reportó 4 vulnerabilidades moderadas (`minimatch` -> `@ts-morph/common` -> `ts-morph` -> `shadcn`) porque el paquete CLI `shadcn` estaba en `dependencies` solo por `@import "shadcn/tailwind.css"`.
   - `next-themes` estaba instalado sin uso real.
5. **Rendimiento en listados admin**:
   - `users-section.tsx` y `local-ads-section.tsx` cargaban todos los registros sin paginación.

### Correcciones aplicadas
- **`next.config.ts`**: agregadas `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy: camera=(), microphone=(), geolocation=()`, `Strict-Transport-Security` y `X-DNS-Prefetch-Control: off`.
- **`lib/security/url.ts`**: creados `isSafeHttpsUrl`, `isSafeStorageImageUrl` y `sanitizeInternalRedirectPath` (bloquea `javascript:`, `data:`, `http:`, `vbscript:`, credenciales en URL, hosts locales/IP y redirecciones externas `//evil.com` o `https://evil.com`).
- **`app/auth/callback/route.ts`**: saneo estricto de `next` y validación de `x-forwarded-host` contra origen permitido.
- **`app/actions/admin-actions.ts`**: verificado `requireAdminSession()` (sesión + `NEXT_PUBLIC_ADMIN_EMAIL` + `karrito.admin_users`) en **todas** las Server Actions de mutación y lectura paginada, con validación estricta en servidor de campos, `action_url` HTTPS y `banner_url`/`interstitial_url`.
- **`app/api/ads/upload/route.ts`**: límite reducido a `2 MB`, solo `image/png`, `image/jpeg`, `image/webp`, nombres con `crypto.randomUUID()` y validación binaria de *magic bytes* antes de subir a `ads-media`.
- **Dependencias**: extraídas las variantes CSS usadas a `app/shadcn-variants.css` y desinstalados `shadcn` y `next-themes` (`removed 164 packages`). **`npm audit` -> 0 vulnerabilidades**.
- **Paginación y columnas explícitas**: `dashboard.ts`, `users-section.tsx` y `local-ads-section.tsx` limitados a **50 registros por página** con botones *Anterior/Siguiente* y selección explícita de columnas (cero `select('*')`).

---

## 5. Aplicación Android `karrito_app` (Flutter)

### Lo revisado
- `android/app/src/main/AndroidManifest.xml`, `lib/data/services/ads_cascade_service.dart`, `lib/ui/widgets/ads_banner_bar.dart`, `lib/ui/widgets/local_interstitial_dialog.dart`, `lib/data/services/ai_classifier_service.dart`, `lib/ui/screens/shopping_list_screen.dart` y `pubspec.yaml`.

### Hallazgos y correcciones aplicadas
1. **`AndroidManifest.xml`**: agregados `android:usesCleartextTraffic="false"` (fuerza HTTPS en toda la app) y `android:allowBackup="false"` (impide extracción de la base SQLite local vía `adb backup`); removido `<data android:scheme="http" />` de `<queries>` manteniendo `https`, `mailto`, `tel` y `geo`.
2. **Validación anti-phishing de URLs en anuncios (`SafeUrlValidator`)**:
   - Creado `lib/domain/services/safe_url_validator.dart` validando esquemas permitidos (`https`, `mailto`, `tel`, `geo`), dominio público válido y ausencia de `userInfo`, bloqueando `http:`, `javascript:`, `data:`, `intent:`, `file:`, IPs y `localhost`.
   - Integrado en `SupabaseAdsCascadeService.refreshLocalAds()` (filtra anuncios o imágenes no seguros antes de guardar/precachear), `KarritoAdsBannerBar` y `LocalInterstitialDialog` (doble control antes de invocar `launchUrl`).
3. **Deduplicación en vuelo de llamadas IA (`ai_classifier_service.dart`)**:
   - Agregado mapa `_inFlightTextRequests` indexado por clave normalizada (`AiResponseCache.normalizeKey`) para que toques duplicados en `+ Agregar` antes de que responda la Edge Function compartan la misma promesa `Future<ProcesarListaResponse>` sin duplicar consultas ni cuota de Gemini, limpiándose siempre en `finally`.
4. **Dependencias limpias (`pubspec.yaml`)**: removida la dependencia directa sin uso `path`.
5. **UX de entrada y scroll (`shopping_list_screen.dart`)**: campo con `BorderRadius.circular(20)`, `minLines: 2`, `maxLines: 3`, `contentPadding: EdgeInsets.fromLTRB(16, 14, 8, 14)` y divisor vertical sutil; fila horizontal única con `Flexible` + `FittedBox(fit: BoxFit.scaleDown)` para `Pegar`, `Frecuentes` y `+ Agregar`; y `SliverAppBar(floating: true, snap: false)` para aparición gradual acompañando el scroll.

---

## 6. Pruebas de verificación ejecutadas

| Capa | Prueba / Comando | Resultado |
|---|---|---|
| Supabase DB & Storage | Query producción `pg_tables`, `pg_policies`, `pg_trigger` y `storage.buckets` | 9/9 tablas con RLS; `ads-media` en `2097152` bytes y `png/jpeg/webp`; `trg_protect_user_fields` y `trg_protect_shopping_list_ownership` activos |
| Supabase Edge Functions | Despliegue en producción `procesar-lista` y `revenuecat-webhook` | Ambas redesplegadas en `jblsngzlpstojzwsdchb` sin errores |
| `karrito_app` (Unit & Widget) | `flutter test` (`safe_url_validator_test.dart`, `ai_classifier_cache_test.dart` con deduplicación en vuelo y `widget_test.dart` en 360 dp con fuente 1.3x + `snap: false`) | **70/70 pruebas en verde** (0 fallos, 0 overflows) |
| `karrito_app` (Análisis & APK) | `dart format .`, `flutter analyze`, auditoría de emojis, `flutter build apk --release --target-platform android-arm,android-arm64 --split-debug-info=build/debug-info` | `0 issues`, `0 emojis` en `lib/`, `apk_lista/karrito-fase5.4.apk` en **49,73 MB** (`52.143.695 bytes`, `< 50 MB`) |
| `karrito_admin` (Seguridad & Build) | `npm audit`, `npm run lint`, `npm run build` | `npm audit`: **0 vulnerabilidades**; `eslint` y `next build` sin errores |
