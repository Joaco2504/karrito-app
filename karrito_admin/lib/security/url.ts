const MAX_URL_LENGTH = 2048;

const IPV4_HOST_REGEX = /^\d{1,3}(\.\d{1,3}){3}$/;

/**
 * Validates that an external ad URL is strictly HTTPS, has a valid public
 * domain name, contains no embedded credentials (phishing vector), and is free
 * of dangerous schemes (`javascript:`, `data:`, `http:`, `vbscript:`, `file:`).
 */
export function isSafeHttpsUrl(raw: string | null | undefined): boolean {
  if (!raw) return false;
  const trimmed = raw.trim();
  if (!trimmed || trimmed.length > MAX_URL_LENGTH) return false;
  // Reject control characters or whitespace inside URL
  if (/[\u0000-\u001f\u007f\s]/.test(trimmed)) return false;

  try {
    const parsed = new URL(trimmed);
    if (parsed.protocol !== "https:") return false;
    if (parsed.username || parsed.password) return false;

    const host = parsed.hostname.toLowerCase();
    if (
      !host ||
      !host.includes(".") ||
      host === "localhost" ||
      host.endsWith(".local") ||
      host.endsWith(".internal") ||
      IPV4_HOST_REGEX.test(host) ||
      host.startsWith("[")
    ) {
      return false;
    }

    return true;
  } catch {
    return false;
  }
}

/**
 * Validates that an uploaded ad asset URL is HTTPS and hosted on the configured
 * Supabase Storage bucket origin (or falls back to strict HTTPS validation if
 * env var is unset during tests).
 */
export function isSafeStorageImageUrl(raw: string | null | undefined): boolean {
  if (!isSafeHttpsUrl(raw)) return false;
  const trimmed = raw!.trim();
  const configuredSupabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL?.trim();
  if (!configuredSupabaseUrl) return true;

  try {
    const expected = new URL(configuredSupabaseUrl);
    const actual = new URL(trimmed);
    return (
      actual.origin === expected.origin &&
      actual.pathname.startsWith("/storage/v1/object/public/ads-media/")
    );
  } catch {
    return false;
  }
}

/**
 * Sanitizes an internal redirect target (e.g. `/auth/callback?next=...`) to
 * block Open Redirect attacks (`https://evil.com`, `//evil.com`, `/\evil.com`).
 */
export function sanitizeInternalRedirectPath(
  raw: string | null | undefined,
): string {
  if (!raw) return "/";
  const trimmed = raw.trim();
  if (!trimmed) return "/";

  // Must start with exactly one `/` and never contain backslashes, control chars,
  // or scheme separators.
  if (
    !trimmed.startsWith("/") ||
    trimmed.startsWith("//") ||
    trimmed.includes("\\") ||
    trimmed.includes("://") ||
    /[\u0000-\u001f\u007f]/.test(trimmed)
  ) {
    return "/";
  }

  // Only allow safe internal paths of the admin panel.
  const pathnameOnly = trimmed.split("?")[0]?.split("#")[0] ?? "/";
  const allowedPrefixes = ["/", "/privacidad"];
  const isAllowed = allowedPrefixes.some(
    (prefix) => pathnameOnly === prefix || pathnameOnly === `${prefix}/`,
  );

  return isAllowed ? pathnameOnly : "/";
}
