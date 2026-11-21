---
name: memory
description: Memoria viva de Karrito con identidad del producto, arquitectura, identificadores fijos, paleta de colores y registro editable de avances. Actualizar tras cada cambio.
---

# Memoria del proyecto Karrito

## Identidad y propuesta de valor
- Nombre de la app: Karrito.
- Propósito: aplicación móvil Android de listas de compras inteligentes que transforma texto desordenado, mensajes de WhatsApp, dictado por voz o fotos de listas en papel en una lista ordenada por comercio y por pasillo real.
- Público y foco inicial: usuarios de Argentina, con despliegue comercial de publicidad local en Andalgalá, Belén, Santa María y Saujil (Catamarca).
- Presupuesto de infraestructura: $0 USD iniciales usando capas gratuitas.

## Identificadores fijos (no modificar sin actualizar todas las plataformas)
- Paquete Android: `com.karrito.app`
- Proyecto Supabase: `karrito-prod`
- Schema PostgreSQL: `karrito`
- Bucket Supabase Storage: `ads-media`
- Edge Functions: `procesar-lista` y `revenuecat-webhook`
- Proyecto Firebase: `karrito-app` (solo para Firebase Cloud Messaging)
- App AdMob: `Karrito Android`
- Bloques AdMob: `karrito_banner_lista` y `karrito_intersticial_lista`
- Proyecto RevenueCat: `Karrito`
- Entitlements RevenueCat: `basic_access` ($2 USD) y `pro_access` ($3 USD)
- Productos Google Play / RevenueCat: `karrito_basic_2usd` y `karrito_pro_3usd`
- Offering RevenueCat: `default`
- Panel web admin: `karrito-admin` (Next.js + Tailwind en Vercel)

## Stack técnico confirmado
- App móvil: Flutter + Riverpod + Drift (SQLite local) + `wakelock_plus` + `record` + `flutter_image_compress` + `google_mobile_ads` + `purchases_flutter` + `firebase_messaging` + `supabase_flutter`.
- Backend y nube: Supabase (Auth anónimo y Google, PostgreSQL en schema `karrito`, Realtime, Storage, Edge Functions en TypeScript).
- Motor de IA: Gemini 4 Hydrogen (`gemini-4-hydrogen`) vía Google AI Studio Interactions API (`v1beta`, `@google/genai@3.6.1`) con salida JSON estructurada (`response_format`). (Reemplaza al deprecado `gemini-2.5-flash`).
- Panel administrativo: Next.js + TypeScript + Tailwind CSS alojado en Vercel, restringido por correo mediante `karrito.admin_users`.

## Reglas de negocio y monetización
- Versión Gratuita: texto libre con IA (tope configurable en `karrito.app_config`, por defecto 5 cargas/día), hasta 3 listas activas, modo tienda offline, reordenamiento de pasillos drag & drop, aprendizaje por corrección, compartir texto por WhatsApp. Muestra publicidad en cascada (primero anuncios locales de la ciudad del usuario; si no hay, Google AdMob).
- Plan Básico ($2 USD/mes, sin plan anual): elimina toda publicidad y amplía a 10 listas activas.
- Plan Pro ($3 USD/mes, sin plan anual): elimina toda publicidad, listas ilimitadas, dictado por voz con IA, escaneo de listas en papel con IA, listas colaborativas en tiempo real (un usuario Pro puede invitar a usuarios gratuitos para tachar en vivo), calculadora de precios en carrito e importador de recetas/proyectos.
- Publicidad local (gestionada desde panel web): Plan Comercio Local Básico ($3 USD/mes, banner inferior) y Plan Comercio Local Destacado ($5 USD/mes, banner más intersticial con botón a WhatsApp o Google Maps).

## Jerarquía de clasificación de productos
1. Supermercado: Verdulería y Frutería, Carnicería y Pescadería, Fiambrería y Quesos, Lácteos y Refrigerados, Panadería, Almacén, Bebidas, Limpieza, Perfumería e Higiene, Congelados, Mascotas.
2. Ferretería / Corralón: Fijaciones, Electricidad e Iluminación, Plomería y Gas, Pinturería, Herramientas, Adhesivos y Selladores.
3. Farmacia: Medicamentos, Primeros Auxilios, Cuidado Personal y Dermocosmética, Bebés y Maternidad.
4. Librería / Papelería: Útiles Escolares, Oficina, Artística.
5. Dietética / Naturista: Frutos Secos y Semillas, Harinas y Cereales, Suplementos, Sin TACC.
6. Otros / Varios: Bazar, Indumentaria, Juguetería y categorías dinámicas.

## Paleta de colores Material 3
- Modo claro: fondo `#FAF7F2`, superficie `#FFFFFF`, primario `#4E1A3D`, secundario `#C86D1F`, completado `#2B6E4E`, texto principal `#1F1A1D`, texto secundario `#6B6268`, bordes `#E5DFD5`.
- Modo oscuro: fondo `#141013`, superficie `#211B20`, primario `#E08EC3`, secundario `#F0A35E`, completado `#5EC293`, texto principal `#F5F0F3`, texto secundario `#A89DA4`, bordes `#362D33`.

## Plan por fases
- Fase 0: Cuentas creadas, schema `karrito` en Supabase, SHA-1 y proyecto Flutter base (Completada).
- Fase 1: Edge Functions `procesar-lista` y `revenuecat-webhook` en Supabase (Completada).
- Fase 2: Núcleo offline en Flutter con Drift, Riverpod, clasificación de texto, pestañas, tachado rápido, wakelock y primer APK (Completada).
- Fase 3: Reordenamiento de pasillos, aprendizaje local, Auth anónimo/Google, sincronización nube y listas compartidas Realtime (Completada).
- Fase 4: Panel admin en Next.js (gestor de publicidad local de $3/$5 USD, métricas, usuarios y `app_config`) en Vercel (Completada).
- Fase 5: AdMob + cascada local, suscripciones RevenueCat, voz, escaneo foto, calculadora, push FCM y publicación en Google Play (Siguiente paso).

## Estructura actual de `karrito_app/`
- `lib/core/config/supabase_config.dart`: URL, clave pública `anon` (`schema: 'karrito'`) y `googleWebClientId` (`client_type: 3` de `android/app/google-services.json`).
- `lib/core/constants/`: `store_hierarchy.dart` (6 rubros, pasillos semilla, localidades de Catamarca, unidades) y `app_strings.dart` (textos `es-AR`).
- `lib/core/theme/app_theme.dart`: temas Material 3 claro/oscuro exactos, `KarritoColors` (`ThemeExtension`) y `SwitchThemeData` con tipografía del sistema.
- `lib/data/local/`: `app_database.dart` + `app_database.g.dart` (Drift SQLite v2 con `local_lists`, `local_items`, `local_aisle_order`, `local_learned_items`, `local_preferences` y `local_pending_deletions`).
- `lib/data/models/`: `procesar_lista_response.dart` (DTOs y parser JSON del contrato de `procesar-lista`).
- `lib/data/services/`: `auth_service.dart` (Guest Mode anónimo y `google_sign_in` + `linkIdentityWithIdToken`/`signInWithIdToken`), `sync_service.dart` (sincronización bidireccional LWW y Supabase Realtime), `ai_classifier_service.dart`, `wakelock_service.dart` y `share_service.dart`.
- `lib/data/repositories/`: `shopping_repository.dart` (ahorro de consultas vía `local_learned_items`, respaldo `pending_ai`, reordenamiento por comercio, suma directa desde `Frecuentes` sin IA y tombstones locales).
- `lib/domain/services/`: `item_text_parser.dart` (normalización sin tildes, parsing de comas/saltos/decimales y detección de texto complejo) y `share_code_helper.dart` (generación y validación de códigos de 6 caracteres).
- `lib/providers/`: `core_providers.dart` y `shopping_providers.dart` (Riverpod 3.5 + `connectivity_plus` + estado de cuenta y controladores de sincronización).
- `lib/ui/`: pantallas (`onboarding_screen.dart`, `shopping_list_screen.dart`, `settings_screen.dart`) y widgets (`aisle_reorder_sheet.dart`, `aisle_section_card.dart`, `edit_item_sheet.dart`, `frequent_items_sheet.dart`, `karrito_selector_field.dart`, `list_selector_sheet.dart`, `live_share_sheets.dart`).

## Estructura actual de `karrito_admin/`
- `app/globals.css` y `app/layout.tsx`: paleta oficial claro/oscuro de Karrito (`#FAF7F2`/`#FFFFFF`/`#4E1A3D`/`#C86D1F`/`#2B6E4E` y equivalentes oscuros), soporte `<meta name="color-scheme">` sin FOUC, `lang="es-AR"`, `<Toaster />` y estilos de tablas responsivas accesibles.
- `middleware.ts`, `app/login/page.tsx`, `app/auth/callback/route.ts` y `lib/auth/admin.ts`: acceso público exclusivo a `/login`, `/auth/callback` y `/privacidad`; todas las rutas y acciones internas validan sesión activa, coincidencia con `NEXT_PUBLIC_ADMIN_EMAIL` y existencia en `karrito.admin_users`, cerrando sesión y avisando acceso denegado ante cuentas no autorizadas.
- `app/privacidad/page.tsx`: política de privacidad pública en español de Argentina lista para Google Play (modo invitado anónimo, Google opcional, procesamiento temporal de audio/foto Pro sin guardado permanente, localidad manual sin GPS, FCM, anuncios locales + AdMob, RevenueCat y baja total de datos).
- `lib/supabase/`: `client.ts` (navegador), `server.ts` (SSR con cookies) y `admin.ts` (`server-only` con `SUPABASE_SERVICE_ROLE_KEY`), todos apuntando a `db: { schema: 'karrito' }`.
- `lib/data/dashboard.ts`, `app/actions/admin-actions.ts` y `app/api/ads/upload/route.ts`: lectura paralela de métricas y tablas, Server Actions autenticadas (`local_ads`, `users_profile`, `app_config`) y subida directa de banners (`320x50`) e intersticiales (`1080x1920`) al bucket público `ads-media`.
- `components/admin/`: `admin-shell.tsx`, `metrics-section.tsx` (usuarios totales, invitados vs Google, planes, cargas IA hoy en hora Argentina UTC-3 y facturación mensual estimada), `local-ads-section.tsx` + `ad-form-dialog.tsx` (CRUD de pauta local, vistas previas, filtro por localidad, CTR y botón «Copiar reporte para WhatsApp»), `users-section.tsx` (buscador, filtros por plan/localidad, cambio de `plan_tier` e interruptor de suspensión `is_banned`) y `config-section.tsx` (edición remota de `app_config`).
- `components/ui/` y `components/theme-toggle.tsx`: primitivos `shadcn/ui` (`base-nova`) adaptados al estándar `karrito-ui-selectors` (etiquetas fijas `13 px`, `min-h-[48px]`, `rounded-[14px]`, superficie `#F5F1EA`/`#2B2329`, tilde verde en selectores e interruptores con contraste en apagado).

## Registro de cambios y estado actual (editable)
- [2026-11-19] Definición completa de Karrito, arquitectura $0 USD, paleta de colores y esquema SQL `karrito` creado en Supabase con RLS activo.
- [2026-11-19] Fase 1 completada: inicializada carpeta `supabase/` vinculada al proyecto `jblsngzlpstojzwsdchb`; creadas y desplegadas las Edge Functions `procesar-lista` (JWT activo, `gemini-4-hydrogen` en `v1beta` Interactions API en reemplazo del deprecado `gemini-2.5-flash`, `db: { schema: 'karrito' }`, control de `is_banned`, límite diario de `app_config.free_daily_ai_limit`, puerta `pro_3usd` para audio M4A / imagen JPEG base64 y mensajes en español argentino) y `revenuecat-webhook` (`--no-verify-jwt`, validación `Bearer REVENUECAT_WEBHOOK_SECRET`, actualización de `plan_tier` para eventos RevenueCat). Contrato de `procesar-lista`: entrada `{ text?, audio_base64?, audio_mime_type?, image_base64?, image_mime_type? }` -> respuesta `{ items: [{ clean_name, quantity, unit, store_category, aisle_name }], quota: { plan_tier, daily_ai_count, daily_ai_limit, remaining } }`. Corregido trigger `karrito.protect_user_sensitive_fields()` en Postgres para validar `auth.role()` y `session_user` (PostgREST ya no popula `request.jwt.claim.role`), desbloqueando actualizaciones desde `service_role` sin permitir modificaciones desde clientes autenticados.
- [2026-11-19] Fase 2 completada: instaladas en `.agents/skills` las skills de Flutter/Riverpod/Drift requeridas; habilitado `enable_anonymous_sign_ins = true` en Supabase (`jblsngzlpstojzwsdchb` y `supabase/config.toml`); creado proyecto `karrito_app/` (`applicationId = "com.karrito.app"`, permisos `INTERNET` y `WAKE_LOCK`, soporte `es-AR`, paleta Material 3 exacta claro/oscuro y textos `es-AR`); implementada base local Drift (`local_lists`, `local_items`, `local_aisle_order`, `local_learned_items`, `local_preferences`), caché local de productos conocidos sin llamadas innecesarias a IA, respaldo offline (`Otros / Varios -> Sin clasificar (sin señal)`, `syncStatus: 'pending_ai'`) con reproceso automático vía `connectivity_plus`, Guest Mode anónimo silencioso, compartir por WhatsApp (`share_plus`), `wakelock_plus`, onboarding inicial y Ajustes con preguntas frecuentes; compilado APK release inicial.
- [2026-11-20] Fase 2.1 (pulido UI, ícono oficial y peso APK): creada skill `.agents/skills/karrito-ui-selectors/SKILL.md` para estandarizar etiquetas fijas superiores (`13 px`), superficies sólidas diferenciadas (`#F5F1EA` / `#2B2329`), bordes `1 px`, radio `14 px` y mínimo táctil `48 px`; creado componente reutilizable `KarritoSelectorField` con selector en `ModalBottomSheet` y tilde verde (`#2B6E4E` / `#5EC293`), aplicado en `edit_item_sheet.dart`, `settings_screen.dart` y `onboarding_screen.dart`; rediseñado `edit_item_sheet.dart` con cantidad/unidad alineados a `48 px`, recálculo automático de `Pasillo` al cambiar `Comercio` y botones horizontales `Quitar` / `Guardar`; agregado `SwitchThemeData` explícito en `app_theme.dart` con contraste en apagado (`#EDE7DF`/`#D0C7BC` claro y `#2B2329`/`#4A3F46` oscuro); configurado ícono oficial `karrito_app/assets/icon/app_icon.png` con `flutter_launcher_icons` adaptativo (`#121212`, `adaptive_icon_foreground_inset: 14`); habilitados `isMinifyEnabled = true`, `isShrinkResources = true` y `proguard-rules.pro` en `build.gradle.kts`, compilando `apk_lista/karrito-fase2.1.apk` con `--target-platform android-arm,android-arm64` (~38 MB) y eliminando `karrito-fase2.apk`.
- [2026-11-20] Fase 3 completada: agregado botón rápido de cambio entre modo claro y oscuro en `shopping_list_screen.dart` persistido en `local_preferences`; agregado reordenamiento de pasillos Drag & Drop por comercio (`aisle_reorder_sheet.dart`) sincronizado con `karrito.aisle_preferences`; creado acceso rápido `Frecuentes` (`frequent_items_sheet.dart`) con buscador local y carga directa sin consumo de Gemini desde `local_learned_items`; configurado Google Sign-In (`google_sign_in`, `google-services.json` en `android/app/` con Web Client ID `client_type: 3`, OAuth y Manual Linking activos en Supabase) en `auth_service.dart` y Ajustes; migrado esquema Drift a v2 agregando columnas colaborativas y `local_pending_deletions`; implementado `sync_service.dart` con sincronización bidireccional LWW (`shopping_lists`, `list_items`, `aisle_preferences`, `learned_items`), compartir lista en vivo con código de 6 caracteres (`plan_tier == 'pro_3usd'`, envío WhatsApp y hoja informativa para Free/Basic), unión mediante RPC `join_shared_list` y suscripción en tiempo real sobre `karrito.list_items` (`live_share_sheets.dart` y `list_selector_sheet.dart`); compilado `apk_lista/karrito-fase3.apk` (39,48 MB) y eliminado `karrito-fase2.1.apk`.
- [2026-11-21] Fase 4 completada: instaladas en `.agents/skills` las skills oficiales de Vercel (`vercel-labs/agent-skills`), `shadcn-ui/ui` y `modern-web-guidance`; creado el panel web administrativo en `karrito_admin/` (Next.js 16 App Router, TypeScript, Tailwind CSS v4, `shadcn/ui` Base UI, `@supabase/supabase-js`, `@supabase/ssr`) con paleta oficial Karrito claro/oscuro y `.env.local` ignorado por Git; implementados clientes Supabase apuntando al schema `karrito` más cliente `service_role` solo de servidor, `middleware.ts`, `/login` con Google OAuth, `/auth/callback` con validación contra `NEXT_PUBLIC_ADMIN_EMAIL` y `karrito.admin_users`, y política de privacidad pública en `/privacidad` en `es-AR`; construidos los 4 módulos del panel (tablero de métricas con fecha Argentina UTC-3 y facturación estimada, gestor de publicidad local con subida directa a `ads-media` y copia de reporte para WhatsApp, gestión de usuarios con cambio de plan y suspensión, y control remoto de `karrito.app_config`); verificados `npm run lint` y `npm run build` sin errores y subido a GitHub.