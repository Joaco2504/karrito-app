import type { AdTier, PlanTier } from "@/lib/types/database";

export const ARGENTINA_TIMEZONE = "America/Argentina/Buenos_Aires";

export const LOCAL_AD_CITIES = [
  "Andalgalá",
  "Belén",
  "Saujil",
  "Santa María",
  "Todas",
] as const;

export const USER_CITIES = [
  "Andalgalá",
  "Belén",
  "Saujil",
  "Santa María",
] as const;

export const PLAN_TIERS: Record<
  PlanTier,
  { label: string; shortLabel: string; priceLabel: string }
> = {
  free: {
    label: "Gratuito",
    shortLabel: "Gratuito",
    priceLabel: "$ 0 USD/mes",
  },
  basic_2usd: {
    label: "Plan Básico ($ 2 USD/mes)",
    shortLabel: "Básico ($ 2 USD)",
    priceLabel: "$ 2 USD/mes",
  },
  pro_3usd: {
    label: "Plan Pro ($ 3 USD/mes)",
    shortLabel: "Pro ($ 3 USD)",
    priceLabel: "$ 3 USD/mes",
  },
};

export const AD_TIERS: Record<
  AdTier,
  {
    label: string;
    shortLabel: string;
    priceUsd: number;
    priceLabel: string;
    description: string;
  }
> = {
  banner_3usd: {
    label: "Plan Comercio Local Básico ($ 3 USD/mes)",
    shortLabel: "Básico ($ 3 USD)",
    priceUsd: 3,
    priceLabel: "$ 3 USD/mes",
    description: "Banner inferior de 320 x 50 px dentro de la lista.",
  },
  featured_5usd: {
    label: "Plan Comercio Local Destacado ($ 5 USD/mes)",
    shortLabel: "Destacado ($ 5 USD)",
    priceUsd: 5,
    priceLabel: "$ 5 USD/mes",
    description:
      "Banner inferior más pantalla intersticial de 1080 x 1920 px con enlace a WhatsApp o Google Maps.",
  },
};

export const APP_CONFIG_FIELDS = [
  {
    key: "free_daily_ai_limit",
    label: "Cargas diarias con IA en plan gratuito",
    help: "Cantidad máxima de veces por día (hora de Argentina) que una cuenta gratuita puede ordenar listas con IA.",
    defaultValue: 5,
    min: 1,
    max: 500,
  },
  {
    key: "free_max_lists",
    label: "Listas activas en plan gratuito",
    help: "Tope de listas simultáneas para cuentas gratuitas.",
    defaultValue: 3,
    min: 1,
    max: 100,
  },
  {
    key: "basic_max_lists",
    label: "Listas activas en plan Básico ($ 2 USD)",
    help: "Tope de listas simultáneas para suscriptores del plan Básico.",
    defaultValue: 10,
    min: 1,
    max: 500,
  },
  {
    key: "pro_max_lists",
    label: "Listas activas en plan Pro ($ 3 USD)",
    help: "Tope técnico de listas para cuentas Pro (por defecto 999, sin límite práctico para el usuario).",
    defaultValue: 999,
    min: 10,
    max: 9999,
  },
] as const;

export type AppConfigKey = (typeof APP_CONFIG_FIELDS)[number]["key"];

export const ADS_STORAGE_BUCKET = "ads-media";

export function getArgentinaDateISO(now = new Date()): string {
  // Argentina mantiene UTC-3 todo el año sin cambio de horario de verano.
  const argMillis = now.getTime() - 3 * 60 * 60 * 1000;
  return new Date(argMillis).toISOString().slice(0, 10);
}

export function getDefaultAdExpiryDateISO(daysFromNow = 30): string {
  const todayArg = getArgentinaDateISO();
  const [year, month, day] = todayArg.split("-").map(Number);
  const utcDate = new Date(Date.UTC(year, month - 1, day + daysFromNow));
  return utcDate.toISOString().slice(0, 10);
}

export function toArgentinaEndOfDayISO(dateISO: string): string {
  // 23:59:59 hora de Argentina (UTC-3).
  return `${dateISO}T23:59:59-03:00`;
}

export function extractArgentinaDateInput(isoTimestamp: string): string {
  if (!isoTimestamp) return getDefaultAdExpiryDateISO(30);
  const parsed = new Date(isoTimestamp);
  if (Number.isNaN(parsed.getTime())) return getDefaultAdExpiryDateISO(30);
  return getArgentinaDateISO(parsed);
}

export function formatDateAR(isoOrDate: string): string {
  if (!isoOrDate) return "—";
  const normalized =
    isoOrDate.length === 10 ? `${isoOrDate}T12:00:00-03:00` : isoOrDate;
  const parsed = new Date(normalized);
  if (Number.isNaN(parsed.getTime())) return isoOrDate;
  return new Intl.DateTimeFormat("es-AR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    timeZone: ARGENTINA_TIMEZONE,
  }).format(parsed);
}

export function formatNumberAR(value: number): string {
  return new Intl.NumberFormat("es-AR").format(value);
}

export function formatPercentAR(value: number): string {
  return `${new Intl.NumberFormat("es-AR", {
    minimumFractionDigits: 1,
    maximumFractionDigits: 2,
  }).format(value)} %`;
}

export function formatUsdAR(value: number): string {
  const formatted = new Intl.NumberFormat("es-AR", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  }).format(value);
  return `$ ${formatted} USD`;
}

export function calculateCtr(clicks: number, impressions: number): number {
  if (!impressions || impressions <= 0) return 0;
  return (clicks / impressions) * 100;
}

export function isAdExpired(expiresAt: string, now = new Date()): boolean {
  const parsed = new Date(expiresAt);
  if (Number.isNaN(parsed.getTime())) return false;
  return parsed.getTime() <= now.getTime();
}
