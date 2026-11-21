export type PlanTier = "free" | "basic_2usd" | "pro_3usd";
export type AdTier = "banner_3usd" | "featured_5usd";

export interface UserProfileRow {
  id: string;
  email: string | null;
  plan_tier: PlanTier;
  city: string;
  daily_ai_count: number;
  last_ai_date: string;
  fcm_token: string | null;
  is_banned: boolean;
  created_at: string;
  updated_at: string;
}

export interface LocalAdRow {
  id: string;
  business_name: string;
  city: string;
  tier: AdTier;
  banner_url: string | null;
  interstitial_url: string | null;
  action_url: string;
  impressions: number;
  clicks: number;
  expires_at: string;
  is_active: boolean;
  created_at: string;
}

export interface AppConfigRow {
  key: string;
  value: string;
  description: string | null;
  updated_at: string;
}

export interface DashboardMetrics {
  totalUsers: number;
  guestUsers: number;
  googleUsers: number;
  planCounts: Record<PlanTier, number>;
  aiLoadsToday: number;
  todayArgentinaISO: string;
  activeAdsCount: number;
  activeBannerAdsCount: number;
  activeFeaturedAdsCount: number;
  estimatedMonthlyRevenueUsd: number;
}

export interface ActionResult<T = undefined> {
  ok: boolean;
  message: string;
  data?: T;
}
