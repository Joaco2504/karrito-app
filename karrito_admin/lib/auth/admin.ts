import "server-only";
import { createAdminSupabaseClient } from "@/lib/supabase/admin";
import { createServerSupabaseClient } from "@/lib/supabase/server";

export function normalizeEmail(email: string | null | undefined): string {
  return (email ?? "").trim().toLowerCase();
}

export function isConfiguredAdminEmail(
  email: string | null | undefined,
): boolean {
  const configured = normalizeEmail(process.env.NEXT_PUBLIC_ADMIN_EMAIL);
  const candidate = normalizeEmail(email);
  return Boolean(configured && candidate && candidate === configured);
}

export async function isEmailInAdminUsers(
  email: string | null | undefined,
): Promise<boolean> {
  const candidate = normalizeEmail(email);
  if (!candidate) return false;

  const adminClient = createAdminSupabaseClient();
  const { data, error } = await adminClient
    .from("admin_users")
    .select("email")
    .ilike("email", candidate)
    .maybeSingle<{ email: string }>();

  if (error || !data) {
    return false;
  }

  return normalizeEmail(data.email) === candidate;
}

export async function verifyAdminAccess(
  email: string | null | undefined,
): Promise<boolean> {
  if (!isConfiguredAdminEmail(email)) {
    return false;
  }
  return isEmailInAdminUsers(email);
}

export type AdminSessionResult =
  | {
      authorized: true;
      userId: string;
      email: string;
    }
  | {
      authorized: false;
      reason: "unauthenticated" | "forbidden";
    };

export async function requireAdminSession(): Promise<AdminSessionResult> {
  const supabase = await createServerSupabaseClient();
  const {
    data: { user },
    error,
  } = await supabase.auth.getUser();

  if (error || !user || !user.email) {
    return { authorized: false, reason: "unauthenticated" };
  }

  const allowed = await verifyAdminAccess(user.email);
  if (!allowed) {
    return { authorized: false, reason: "forbidden" };
  }

  return {
    authorized: true,
    userId: user.id,
    email: user.email,
  };
}
