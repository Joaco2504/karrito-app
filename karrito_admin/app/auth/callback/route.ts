import { NextResponse, type NextRequest } from "next/server";
import { verifyAdminAccess } from "@/lib/auth/admin";
import { createServerSupabaseClient } from "@/lib/supabase/server";

function getSafeOrigin(request: NextRequest): string {
  const forwardedHost = request.headers.get("x-forwarded-host");
  const forwardedProto = request.headers.get("x-forwarded-proto") ?? "https";
  if (forwardedHost && process.env.NODE_ENV !== "development") {
    return `${forwardedProto}://${forwardedHost}`;
  }
  return request.nextUrl.origin;
}

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;
  const code = searchParams.get("code");
  const oauthError = searchParams.get("error");
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

  return NextResponse.redirect(`${origin}/`);
}
