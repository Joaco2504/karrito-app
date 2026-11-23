import { NextResponse, type NextRequest } from "next/server";
import { verifyAdminAccess } from "@/lib/auth/admin";
import { sanitizeInternalRedirectPath } from "@/lib/security/url";
import { createServerSupabaseClient } from "@/lib/supabase/server";

const SAFE_HOST_REGEX = /^[a-z0-9.-]+(?::\d{1,5})?$/i;

function getSafeOrigin(request: NextRequest): string {
  const configuredSiteUrl = process.env.NEXT_PUBLIC_SITE_URL?.trim();
  if (configuredSiteUrl) {
    try {
      const parsed = new URL(configuredSiteUrl);
      if (parsed.protocol === "https:") {
        return parsed.origin;
      }
    } catch {
      // Fall back to verified request origin below.
    }
  }

  const forwardedHost = request.headers.get("x-forwarded-host")?.trim() ?? "";
  const requestHost = request.nextUrl.host;
  if (
    forwardedHost &&
    process.env.NODE_ENV !== "development" &&
    SAFE_HOST_REGEX.test(forwardedHost) &&
    (forwardedHost === requestHost || forwardedHost.endsWith(".vercel.app"))
  ) {
    return `https://${forwardedHost}`;
  }

  return request.nextUrl.origin;
}

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;
  const code = searchParams.get("code");
  const oauthError = searchParams.get("error");
  const safeNextPath = sanitizeInternalRedirectPath(searchParams.get("next"));
  const origin = getSafeOrigin(request);

  if (oauthError || !code) {
    return NextResponse.redirect(`${origin}/login?error=auth_error`);
  }

  const supabase = await createServerSupabaseClient();
  const { data, error } = await supabase.auth.exchangeCodeForSession(code);

  if (error || !data.user) {
    return NextResponse.redirect(`${origin}/login?error=auth_error`);
  }

  const isAllowed = await verifyAdminAccess(data.user.email);
  if (!isAllowed) {
    await supabase.auth.signOut();
    return NextResponse.redirect(`${origin}/login?error=acceso_denegado`);
  }

  return NextResponse.redirect(`${origin}${safeNextPath}`);
}
