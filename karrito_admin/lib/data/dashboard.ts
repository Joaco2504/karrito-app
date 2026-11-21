import "server-only";
import {
  AD_TIERS,
  getArgentinaDateISO,
  isAdExpired,
} from "@/lib/constants/karrito";
import { createAdminSupabaseClient } from "@/lib/supabase/admin";
import type {
  AppConfigRow,
  DashboardMetrics,
  LocalAdRow,
  PlanTier,
  UserProfileRow,
} from "@/lib/types/database";

export interface AdminDashboardData {
  metrics: DashboardMetrics;
  users: UserProfileRow[];
  ads: LocalAdRow[];
  config: AppConfigRow[];
}

export async function getAdminDashboardData(): Promise<AdminDashboardData> {
  const adminClient = createAdminSupabaseClient();

  const [usersRes, adsRes, configRes] = await Promise.all([
    adminClient
      .from("users_profile")
      .select(
        "id, email, plan_tier, city, daily_ai_count, last_ai_date, fcm_token, is_banned, created_at, updated_at",
      )
      .order("created_at", { ascending: false }),
    adminClient
      .from("local_ads")
      .select(
        "id, business_name, city, tier, banner_url, interstitial_url, action_url, impressions, clicks, expires_at, is_active, created_at",
      )
      .order("created_at", { ascending: false }),
    adminClient
      .from("app_config")
      .select("key, value, description, updated_at")
      .order("key", { ascending: true }),
  ]);

  if (usersRes.error) {
    throw new Error(
      `Error al consultar karrito.users_profile: ${usersRes.error.message}`,
    );
  }
  if (adsRes.error) {
    throw new Error(
      `Error al consultar karrito.local_ads: ${adsRes.error.message}`,
    );
  }
  if (configRes.error) {
    throw new Error(
      `Error al consultar karrito.app_config: ${configRes.error.message}`,
    );
  }

  const users = (usersRes.data ?? []) as UserProfileRow[];
  const ads = (adsRes.data ?? []) as LocalAdRow[];
  const config = (configRes.data ?? []) as AppConfigRow[];

  const now = new Date();
  const todayArgentinaISO = getArgentinaDateISO(now);

  let guestUsers = 0;
  let googleUsers = 0;
  let aiLoadsToday = 0;
  const planCounts: Record<PlanTier, number> = {
    free: 0,
    basic_2usd: 0,
    pro_3usd: 0,
  };

  for (const user of users) {
    if (user.email && user.email.trim().length > 0) {
      googleUsers += 1;
    } else {
      guestUsers += 1;
    }

    if (user.plan_tier in planCounts) {
      planCounts[user.plan_tier] += 1;
    }

    if (user.last_ai_date === todayArgentinaISO && user.daily_ai_count > 0) {
      aiLoadsToday += user.daily_ai_count;
    }
  }

  let activeBannerAdsCount = 0;
  let activeFeaturedAdsCount = 0;

  for (const ad of ads) {
    if (ad.is_active && !isAdExpired(ad.expires_at, now)) {
      if (ad.tier === "featured_5usd") {
        activeFeaturedAdsCount += 1;
      } else {
        activeBannerAdsCount += 1;
      }
    }
  }

  const estimatedMonthlyRevenueUsd =
    activeBannerAdsCount * AD_TIERS.banner_3usd.priceUsd +
    activeFeaturedAdsCount * AD_TIERS.featured_5usd.priceUsd;

  return {
    metrics: {
      totalUsers: users.length,
      guestUsers,
      googleUsers,
      planCounts,
      aiLoadsToday,
      todayArgentinaISO,
      activeAdsCount: activeBannerAdsCount + activeFeaturedAdsCount,
      activeBannerAdsCount,
      activeFeaturedAdsCount,
      estimatedMonthlyRevenueUsd,
    },
    users,
    ads,
    config,
  };
}
