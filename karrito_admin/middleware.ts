import { NextResponse, type NextRequest } from "next/server";
import { createServerClient } from "@supabase/ssr";

const PUBLIC_PATHS = ["/login", "/auth/callback", "/privacidad"];

function isPublicPath(pathname: string): boolean {
  return PUBLIC_PATHS.some(
    (publicPath) =>
      pathname === publicPath || pathname.startsWith(`${publicPath}/`),
  );
}

function copyCookies(from: NextResponse, to: NextResponse) {
  for (const cookie of from.cookies.getAll()) {
    to.cookies.set(cookie);
  }
}

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // /privacidad y /auth/callback siempre pasan sin exigir sesión previa.
  if (
    pathname === "/privacidad" ||
    pathname.startsWith("/privacidad/") ||
    pathname === "/auth/callback" ||
    pathname.startsWith("/auth/callback/")
  ) {
    return NextResponse.next();
  }

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  const configuredAdminEmail = (process.env.NEXT_PUBLIC_ADMIN_EMAIL ?? "")
    .trim()
    .toLowerCase();

  if (!supabaseUrl || !supabaseAnonKey) {
    if (isPublicPath(pathname)) {
      return NextResponse.next();
    }
    const loginUrl = request.nextUrl.clone();
    loginUrl.pathname = "/login";
    loginUrl.searchParams.set("error", "config_error");
    return NextResponse.redirect(loginUrl);
  }

  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(supabaseUrl, supabaseAnonKey, {
    db: { schema: "karrito" },
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet) {
        for (const { name, value } of cookiesToSet) {
          request.cookies.set(name, value);
        }
        supabaseResponse = NextResponse.next({ request });
        for (const { name, value, options } of cookiesToSet) {
          supabaseResponse.cookies.set(name, value, options);
        }
      },
    },
  });

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (pathname === "/login" || pathname.startsWith("/login/")) {
    const hasErrorParam = request.nextUrl.searchParams.has("error");
    if (user?.email && !hasErrorParam) {
      const normalized = user.email.trim().toLowerCase();
      if (configuredAdminEmail && normalized === configuredAdminEmail) {
        const { data: adminRow } = await supabase
          .from("admin_users")
          .select("email")
          .ilike("email", normalized)
          .maybeSingle<{ email: string }>();

        if (adminRow) {
          const homeUrl = request.nextUrl.clone();
          homeUrl.pathname = "/";
          homeUrl.search = "";
          const redirectRes = NextResponse.redirect(homeUrl);
          copyCookies(supabaseResponse, redirectRes);
          return redirectRes;
        }
      }
    }
    return supabaseResponse;
  }

  // Rutas protegidas del panel y APIs internas.
  if (!user) {
    if (pathname.startsWith("/api/")) {
      return NextResponse.json(
        { error: "Tenés que iniciar sesión para hacer esta operación." },
        { status: 401 },
      );
    }
    const loginUrl = request.nextUrl.clone();
    loginUrl.pathname = "/login";
    loginUrl.search = "";
    const redirectRes = NextResponse.redirect(loginUrl);
    copyCookies(supabaseResponse, redirectRes);
    return redirectRes;
  }

  const userEmail = (user.email ?? "").trim().toLowerCase();
  const matchesEnvEmail =
    Boolean(configuredAdminEmail) && userEmail === configuredAdminEmail;

  let existsInAdminTable = false;
  if (matchesEnvEmail) {
    const { data: adminRow } = await supabase
      .from("admin_users")
      .select("email")
      .ilike("email", userEmail)
      .maybeSingle<{ email: string }>();
    existsInAdminTable = Boolean(adminRow?.email);
  }

  if (!matchesEnvEmail || !existsInAdminTable) {
    await supabase.auth.signOut();

    if (pathname.startsWith("/api/")) {
      const forbiddenRes = NextResponse.json(
        { error: "Esta cuenta no tiene permisos de administración en Karrito." },
        { status: 403 },
      );
      copyCookies(supabaseResponse, forbiddenRes);
      return forbiddenRes;
    }

    const deniedUrl = request.nextUrl.clone();
    deniedUrl.pathname = "/login";
    deniedUrl.search = "";
    deniedUrl.searchParams.set("error", "acceso_denegado");
    const redirectRes = NextResponse.redirect(deniedUrl);
    copyCookies(supabaseResponse, redirectRes);
    return redirectRes;
  }

  return supabaseResponse;
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp|ico)$).*)",
  ],
};
