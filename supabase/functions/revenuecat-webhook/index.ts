import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "@supabase/supabase-js";

type PlanTier = "free" | "basic_2usd" | "pro_3usd";

interface RevenueCatEvent {
  type?: unknown;
  id?: unknown;
  app_user_id?: unknown;
  original_app_user_id?: unknown;
  aliases?: unknown;
  entitlement_ids?: unknown;
  entitlement_id?: unknown;
  product_id?: unknown;
  new_product_id?: unknown;
  expiration_at_ms?: unknown;
  cancel_reason?: unknown;
}

const HANDLED_EVENTS = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
  "PRODUCT_CHANGE",
  "EXPIRATION",
  "CANCELLATION",
]);

const UUID_REGEX =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json; charset=utf-8" },
  });
}

function constantTimeEquals(a: string, b: string): boolean {
  const encoder = new TextEncoder();
  const aBytes = encoder.encode(a);
  const bBytes = encoder.encode(b);
  if (aBytes.length !== bBytes.length) return false;

  let diff = 0;
  for (let i = 0; i < aBytes.length; i++) {
    diff |= aBytes[i] ^ bBytes[i];
  }
  return diff === 0;
}

function extractSupabaseUserId(event: RevenueCatEvent): string | null {
  const candidates: unknown[] = [
    event.app_user_id,
    event.original_app_user_id,
    ...(Array.isArray(event.aliases) ? event.aliases : []),
  ];

  for (const candidate of candidates) {
    if (typeof candidate === "string") {
      const trimmed = candidate.trim();
      if (UUID_REGEX.test(trimmed)) {
        return trimmed.toLowerCase();
      }
    }
  }

  return null;
}

function tierFromProductId(productId: unknown): PlanTier | null {
  if (typeof productId !== "string") return null;
  const normalized = productId.trim().toLowerCase();
  if (normalized === "karrito_pro_3usd" || normalized.includes("pro_3usd")) {
    return "pro_3usd";
  }
  if (normalized === "karrito_basic_2usd" || normalized.includes("basic_2usd")) {
    return "basic_2usd";
  }
  return null;
}

function resolveActiveEntitlementTier(event: RevenueCatEvent): PlanTier {
  if (Array.isArray(event.entitlement_ids)) {
    const entitlements = new Set(
      event.entitlement_ids
        .filter((item): item is string => typeof item === "string")
        .map((item) => item.trim()),
    );
    if (entitlements.has("pro_access")) return "pro_3usd";
    if (entitlements.has("basic_access")) return "basic_2usd";
    // Explicit empty or unrecognized entitlement_ids means no active paid entitlement.
    if (event.type !== "PRODUCT_CHANGE") {
      return "free";
    }
  }

  if (typeof event.entitlement_id === "string") {
    const single = event.entitlement_id.trim();
    if (single === "pro_access") return "pro_3usd";
    if (single === "basic_access") return "basic_2usd";
  }

  if (event.type === "PRODUCT_CHANGE") {
    const upgraded = tierFromProductId(event.new_product_id);
    if (upgraded) return upgraded;
  }

  return tierFromProductId(event.product_id) ?? "free";
}

function resolveNextPlanTier(
  eventType: string,
  event: RevenueCatEvent,
): PlanTier {
  if (eventType === "EXPIRATION") {
    return "free";
  }

  const expirationAtMs = typeof event.expiration_at_ms === "number"
    ? event.expiration_at_ms
    : null;
  const isExpired = expirationAtMs !== null && expirationAtMs <= Date.now();

  if (eventType === "CANCELLATION") {
    // Immediate refunds/revocations or expired periods drop to free at once;
    // normal auto-renew cancellations retain paid access until EXPIRATION fires.
    const isRevoked = event.cancel_reason === "CUSTOMER_SUPPORT";
    if (isRevoked || isExpired || expirationAtMs === null) {
      return "free";
    }
    return resolveActiveEntitlementTier(event);
  }

  if (isExpired) {
    return "free";
  }

  return resolveActiveEntitlementTier(event);
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const webhookSecret = Deno.env.get("REVENUECAT_WEBHOOK_SECRET") ?? "";
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

  if (!webhookSecret || !supabaseUrl || !supabaseServiceRoleKey) {
    console.error("Missing required server environment variables.");
    return jsonResponse({ error: "Server misconfigured" }, 500);
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  const expectedHeader = `Bearer ${webhookSecret}`;
  if (!constantTimeEquals(authHeader, expectedHeader)) {
    return jsonResponse({ error: "Unauthorized" }, 401);
  }

  let body: { event?: RevenueCatEvent };
  try {
    body = (await req.json()) as { event?: RevenueCatEvent };
  } catch {
    return jsonResponse({ error: "Invalid JSON payload" }, 400);
  }

  const event = body?.event;
  if (!event || typeof event.type !== "string") {
    return jsonResponse({ error: "Missing event payload" }, 400);
  }

  const eventType = event.type.trim();

  if (eventType === "TEST") {
    return jsonResponse({ ok: true, event_type: "TEST" }, 200);
  }

  if (!HANDLED_EVENTS.has(eventType)) {
    return jsonResponse({ ok: true, ignored: true, event_type: eventType }, 200);
  }

  const userId = extractSupabaseUserId(event);
  if (!userId) {
    console.warn("RevenueCat event ignored: no valid UUID in app_user_id/aliases", {
      event_type: eventType,
      app_user_id: event.app_user_id,
    });
    return jsonResponse(
      { ok: true, ignored: true, reason: "No valid Supabase user UUID" },
      200,
    );
  }

  const nextPlanTier = resolveNextPlanTier(eventType, event);

  const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey, {
    db: { schema: "karrito" },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: updatedUser, error: updateError } = await supabaseAdmin
    .from("users_profile")
    .update({ plan_tier: nextPlanTier })
    .eq("id", userId)
    .select("id, plan_tier")
    .maybeSingle<{ id: string; plan_tier: PlanTier }>();

  if (updateError) {
    console.error("Failed to update karrito.users_profile:", updateError);
    return jsonResponse({ error: "Database update failed" }, 500);
  }

  if (!updatedUser) {
    return jsonResponse({ error: "User profile not found" }, 404);
  }

  return jsonResponse({
    ok: true,
    user_id: updatedUser.id,
    event_type: eventType,
    plan_tier: updatedUser.plan_tier,
  });
});
