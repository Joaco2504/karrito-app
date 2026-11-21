"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireAdminSession } from "@/lib/auth/admin";
import {
  ADS_STORAGE_BUCKET,
  APP_CONFIG_FIELDS,
  LOCAL_AD_CITIES,
  toArgentinaEndOfDayISO,
  type AppConfigKey,
} from "@/lib/constants/karrito";
import { createAdminSupabaseClient } from "@/lib/supabase/admin";
import { createServerSupabaseClient } from "@/lib/supabase/server";
import type {
  ActionResult,
  AdTier,
  AppConfigRow,
  LocalAdRow,
  PlanTier,
  UserProfileRow,
} from "@/lib/types/database";

const VALID_PLAN_TIERS = new Set<PlanTier>([
  "free",
  "basic_2usd",
  "pro_3usd",
]);
const VALID_AD_TIERS = new Set<AdTier>(["banner_3usd", "featured_5usd"]);
const VALID_AD_CITIES = new Set<string>(LOCAL_AD_CITIES);
const UUID_REGEX =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const DATE_ISO_REGEX = /^\d{4}-\d{2}-\d{2}$/;

function isValidHttpUrl(raw: string): boolean {
  try {
    const parsed = new URL(raw);
    return parsed.protocol === "https:" || parsed.protocol === "http:";
  } catch {
    return false;
  }
}

function extractBucketPath(publicUrl: string | null): string | null {
  if (!publicUrl) return null;
  const marker = `/storage/v1/object/public/${ADS_STORAGE_BUCKET}/`;
  const idx = publicUrl.indexOf(marker);
  if (idx === -1) return null;
  const rawPath = publicUrl.slice(idx + marker.length).split("?")[0];
  return rawPath ? decodeURIComponent(rawPath) : null;
}

export async function signOutAdminAction(): Promise<void> {
  const supabase = await createServerSupabaseClient();
  await supabase.auth.signOut();
  redirect("/login");
}

export interface SaveLocalAdInput {
  id?: string;
  business_name: string;
  city: string;
  tier: AdTier;
  banner_url: string;
  interstitial_url: string;
  action_url: string;
  expires_date: string;
  is_active: boolean;
}

export async function saveLocalAdAction(
  input: SaveLocalAdInput,
): Promise<ActionResult<LocalAdRow>> {
  const session = await requireAdminSession();
  if (!session.authorized) {
    return {
      ok: false,
      message:
        "Tu sesión de administración venció o no tiene permisos. Volvé a entrar con Google.",
    };
  }

  const businessName = input.business_name.trim();
  if (businessName.length < 2) {
    return {
      ok: false,
      message: "Escribí el nombre del comercio (al menos 2 caracteres).",
    };
  }

  if (!VALID_AD_CITIES.has(input.city)) {
    return {
      ok: false,
      message: "Elegí una localidad válida de la lista.",
    };
  }

  if (!VALID_AD_TIERS.has(input.tier)) {
    return {
      ok: false,
      message: "Elegí un plan publicitario válido.",
    };
  }

  const bannerUrl = input.banner_url.trim();
  if (!bannerUrl || !isValidHttpUrl(bannerUrl)) {
    return {
      ok: false,
      message:
        "Subí la imagen del banner (320 x 50 px) antes de guardar el anuncio.",
    };
  }

  const interstitialUrl =
    input.tier === "featured_5usd" ? input.interstitial_url.trim() : "";
  if (
    input.tier === "featured_5usd" &&
    (!interstitialUrl || !isValidHttpUrl(interstitialUrl))
  ) {
    return {
      ok: false,
      message:
        "Para el Plan Comercio Local Destacado ($ 5 USD) tenés que subir también la imagen intersticial (1080 x 1920 px).",
    };
  }

  const actionUrl = input.action_url.trim();
  if (!actionUrl || !isValidHttpUrl(actionUrl)) {
    return {
      ok: false,
      message:
        "Ingresá un enlace válido de WhatsApp o Google Maps que empiece con https://.",
    };
  }

  if (!DATE_ISO_REGEX.test(input.expires_date)) {
    return {
      ok: false,
      message: "Elegí una fecha de vencimiento válida.",
    };
  }

  const payload = {
    business_name: businessName,
    city: input.city,
    tier: input.tier,
    banner_url: bannerUrl,
    interstitial_url: interstitialUrl || null,
    action_url: actionUrl,
    expires_at: toArgentinaEndOfDayISO(input.expires_date),
    is_active: Boolean(input.is_active),
  };

  const adminClient = createAdminSupabaseClient();

  if (input.id) {
    if (!UUID_REGEX.test(input.id)) {
      return { ok: false, message: "Identificador de anuncio inválido." };
    }

    const { data, error } = await adminClient
      .from("local_ads")
      .update(payload)
      .eq("id", input.id)
      .select(
        "id, business_name, city, tier, banner_url, interstitial_url, action_url, impressions, clicks, expires_at, is_active, created_at",
      )
      .single<LocalAdRow>();

    if (error || !data) {
      return {
        ok: false,
        message: `No pudimos actualizar el anuncio en Supabase: ${error?.message ?? "error desconocido"}.`,
      };
    }

    revalidatePath("/");
    return {
      ok: true,
      message: `Cambios guardados en ${data.business_name}.`,
      data,
    };
  }

  const { data, error } = await adminClient
    .from("local_ads")
    .insert(payload)
    .select(
      "id, business_name, city, tier, banner_url, interstitial_url, action_url, impressions, clicks, expires_at, is_active, created_at",
    )
    .single<LocalAdRow>();

  if (error || !data) {
    return {
      ok: false,
      message: `No pudimos crear el anuncio en Supabase: ${error?.message ?? "error desconocido"}.`,
    };
  }

  revalidatePath("/");
  return {
    ok: true,
    message: `Anuncio de ${data.business_name} creado.`,
    data,
  };
}

export async function toggleLocalAdActiveAction(
  adId: string,
  nextActive: boolean,
): Promise<ActionResult<LocalAdRow>> {
  const session = await requireAdminSession();
  if (!session.authorized) {
    return {
      ok: false,
      message:
        "Tu sesión de administración venció o no tiene permisos. Volvé a entrar con Google.",
    };
  }

  if (!UUID_REGEX.test(adId)) {
    return { ok: false, message: "Identificador de anuncio inválido." };
  }

  const adminClient = createAdminSupabaseClient();
  const { data, error } = await adminClient
    .from("local_ads")
    .update({ is_active: Boolean(nextActive) })
    .eq("id", adId)
    .select(
      "id, business_name, city, tier, banner_url, interstitial_url, action_url, impressions, clicks, expires_at, is_active, created_at",
    )
    .single<LocalAdRow>();

  if (error || !data) {
    return {
      ok: false,
      message: `No pudimos cambiar el estado del anuncio: ${error?.message ?? "error desconocido"}.`,
    };
  }

  revalidatePath("/");
  return {
    ok: true,
    message: data.is_active
      ? `${data.business_name} quedó activo.`
      : `${data.business_name} quedó pausado.`,
    data,
  };
}

export async function deleteLocalAdAction(
  adId: string,
): Promise<ActionResult<{ id: string }>> {
  const session = await requireAdminSession();
  if (!session.authorized) {
    return {
      ok: false,
      message:
        "Tu sesión de administración venció o no tiene permisos. Volvé a entrar con Google.",
    };
  }

  if (!UUID_REGEX.test(adId)) {
    return { ok: false, message: "Identificador de anuncio inválido." };
  }

  const adminClient = createAdminSupabaseClient();

  const { data: existing } = await adminClient
    .from("local_ads")
    .select("business_name, banner_url, interstitial_url")
    .eq("id", adId)
    .maybeSingle<{
      business_name: string;
      banner_url: string | null;
      interstitial_url: string | null;
    }>();

  const { error } = await adminClient
    .from("local_ads")
    .delete()
    .eq("id", adId);

  if (error) {
    return {
      ok: false,
      message: `No pudimos borrar el anuncio: ${error.message}.`,
    };
  }

  // Limpia las imágenes del bucket ads-media si pertenecen a este proyecto.
  const pathsToRemove = [
    extractBucketPath(existing?.banner_url ?? null),
    extractBucketPath(existing?.interstitial_url ?? null),
  ].filter((value): value is string => Boolean(value));

  if (pathsToRemove.length > 0) {
    await adminClient.storage.from(ADS_STORAGE_BUCKET).remove(pathsToRemove);
  }

  revalidatePath("/");
  return {
    ok: true,
    message: existing?.business_name
      ? `Borramos el anuncio de ${existing.business_name}.`
      : "Anuncio borrado.",
    data: { id: adId },
  };
}

export async function updateUserPlanAction(
  userId: string,
  planTier: PlanTier,
): Promise<ActionResult<UserProfileRow>> {
  const session = await requireAdminSession();
  if (!session.authorized) {
    return {
      ok: false,
      message:
        "Tu sesión de administración venció o no tiene permisos. Volvé a entrar con Google.",
    };
  }

  if (!UUID_REGEX.test(userId) || !VALID_PLAN_TIERS.has(planTier)) {
    return {
      ok: false,
      message: "Los datos de usuario o plan no son válidos.",
    };
  }

  const adminClient = createAdminSupabaseClient();
  const { data, error } = await adminClient
    .from("users_profile")
    .update({ plan_tier: planTier })
    .eq("id", userId)
    .select(
      "id, email, plan_tier, city, daily_ai_count, last_ai_date, fcm_token, is_banned, created_at, updated_at",
    )
    .single<UserProfileRow>();

  if (error || !data) {
    return {
      ok: false,
      message: `No pudimos cambiar el plan de la cuenta: ${error?.message ?? "error desconocido"}.`,
    };
  }

  revalidatePath("/");
  return {
    ok: true,
    message: "Plan actualizado.",
    data,
  };
}

export async function toggleUserBannedAction(
  userId: string,
  isBanned: boolean,
): Promise<ActionResult<UserProfileRow>> {
  const session = await requireAdminSession();
  if (!session.authorized) {
    return {
      ok: false,
      message:
        "Tu sesión de administración venció o no tiene permisos. Volvé a entrar con Google.",
    };
  }

  if (!UUID_REGEX.test(userId)) {
    return { ok: false, message: "Identificador de usuario inválido." };
  }

  if (userId === session.userId && isBanned) {
    return {
      ok: false,
      message:
        "No podés suspender tu propia cuenta administradora desde el panel.",
    };
  }

  const adminClient = createAdminSupabaseClient();
  const { data, error } = await adminClient
    .from("users_profile")
    .update({ is_banned: Boolean(isBanned) })
    .eq("id", userId)
    .select(
      "id, email, plan_tier, city, daily_ai_count, last_ai_date, fcm_token, is_banned, created_at, updated_at",
    )
    .single<UserProfileRow>();

  if (error || !data) {
    return {
      ok: false,
      message: `No pudimos actualizar el estado de la cuenta: ${error?.message ?? "error desconocido"}.`,
    };
  }

  revalidatePath("/");
  return {
    ok: true,
    message: data.is_banned
      ? "Cuenta suspendida. Ya no puede sincronizar ni usar IA."
      : "Cuenta habilitada de nuevo.",
    data,
  };
}

export async function saveAppConfigAction(
  values: Record<AppConfigKey, number>,
): Promise<ActionResult<AppConfigRow[]>> {
  const session = await requireAdminSession();
  if (!session.authorized) {
    return {
      ok: false,
      message:
        "Tu sesión de administración venció o no tiene permisos. Volvé a entrar con Google.",
    };
  }

  const rowsToUpsert: Array<{
    key: AppConfigKey;
    value: string;
    description: string;
  }> = [];

  for (const field of APP_CONFIG_FIELDS) {
    const raw = values[field.key];
    if (
      typeof raw !== "number" ||
      !Number.isInteger(raw) ||
      raw < field.min ||
      raw > field.max
    ) {
      return {
        ok: false,
        message: `El valor de «${field.label}» tiene que ser un número entero entre ${field.min} y ${field.max}.`,
      };
    }

    rowsToUpsert.push({
      key: field.key,
      value: String(raw),
      description: field.help,
    });
  }

  const adminClient = createAdminSupabaseClient();
  const { data, error } = await adminClient
    .from("app_config")
    .upsert(rowsToUpsert, { onConflict: "key" })
    .select("key, value, description, updated_at")
    .order("key", { ascending: true });

  if (error || !data) {
    return {
      ok: false,
      message: `No pudimos guardar la configuración en Supabase: ${error?.message ?? "error desconocido"}.`,
    };
  }

  revalidatePath("/");
  return {
    ok: true,
    message: "Configuración guardada. Los límites nuevos ya rigen en la app.",
    data: data as AppConfigRow[],
  };
}
