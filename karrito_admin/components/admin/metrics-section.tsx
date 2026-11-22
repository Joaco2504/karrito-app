"use client";

import {
  ArrowRightIcon,
  CoinsIcon,
  MegaphoneIcon,
  SlidersHorizontalIcon,
  SparklesIcon,
  UsersIcon,
} from "lucide-react";
import {
  LOCAL_AD_CITIES,
  formatDateAR,
  formatNumberAR,
  formatUsdAR,
  isAdExpired,
} from "@/lib/constants/karrito";
import type { DashboardMetrics, LocalAdRow } from "@/lib/types/database";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export type AdminTabKey = "resumen" | "publicidad" | "usuarios" | "configuracion";

interface MetricsSectionProps {
  metrics: DashboardMetrics;
  ads: LocalAdRow[];
  onNavigateTab: (tab: AdminTabKey) => void;
  onOpenNewAd: () => void;
}

export function MetricsSection({
  metrics,
  ads,
  onNavigateTab,
  onOpenNewAd,
}: MetricsSectionProps) {
  const googleRatio =
    metrics.totalUsers > 0
      ? Math.round((metrics.googleUsers / metrics.totalUsers) * 100)
      : 0;

  const activeAdsByCity = LOCAL_AD_CITIES.map((city) => {
    const count = ads.filter(
      (ad) => ad.city === city && ad.is_active && !isAdExpired(ad.expires_at),
    ).length;
    return { city, count };
  });

  return (
    <section aria-label="Tablero de métricas" className="flex flex-col gap-6">
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <Card className="karrito-card-elevation rounded-3xl border border-border bg-card">
          <CardHeader className="flex flex-row items-start justify-between gap-2 pb-2">
            <div className="flex flex-col gap-1">
              <CardDescription className="text-[13px] font-semibold">
                Usuarios totales
              </CardDescription>
              <CardTitle className="text-3xl font-extrabold tracking-tight tabular-nums">
                {formatNumberAR(metrics.totalUsers)}
              </CardTitle>
            </div>
            <div className="flex size-10 items-center justify-center rounded-2xl bg-brand-accent text-brand-accent-foreground">
              <UsersIcon className="size-5" aria-hidden="true" />
            </div>
          </CardHeader>
          <CardContent className="flex flex-col gap-2 pt-1">
            <div className="flex items-center justify-between text-xs text-muted-foreground">
              <span>Invitados anónimos</span>
              <span className="font-semibold text-foreground tabular-nums">
                {formatNumberAR(metrics.guestUsers)}
              </span>
            </div>
            <div className="flex items-center justify-between text-xs text-muted-foreground">
              <span>Vinculados con Google ({googleRatio} %)</span>
              <span className="font-semibold text-foreground tabular-nums">
                {formatNumberAR(metrics.googleUsers)}
              </span>
            </div>
          </CardContent>
        </Card>

        <Card className="karrito-card-elevation rounded-3xl border border-border bg-card">
          <CardHeader className="flex flex-row items-start justify-between gap-2 pb-2">
            <div className="flex flex-col gap-1">
              <CardDescription className="text-[13px] font-semibold">
                Cuentas por plan
              </CardDescription>
              <CardTitle className="text-3xl font-extrabold tracking-tight tabular-nums">
                {formatNumberAR(
                  metrics.planCounts.basic_2usd + metrics.planCounts.pro_3usd,
                )}
              </CardTitle>
            </div>
            <div className="flex size-10 items-center justify-center rounded-2xl bg-brand-cta text-brand-cta-foreground">
              <MegaphoneIcon className="size-5" aria-hidden="true" />
            </div>
          </CardHeader>
          <CardContent className="flex flex-col gap-1.5 pt-1 text-xs">
            <div className="flex items-center justify-between text-muted-foreground">
              <span>Gratuito (free)</span>
              <span className="font-semibold text-foreground tabular-nums">
                {formatNumberAR(metrics.planCounts.free)}
              </span>
            </div>
            <div className="flex items-center justify-between text-muted-foreground">
              <span>Plan Básico ($ 2 USD)</span>
              <span className="font-semibold text-foreground tabular-nums">
                {formatNumberAR(metrics.planCounts.basic_2usd)}
              </span>
            </div>
            <div className="flex items-center justify-between text-muted-foreground">
              <span>Plan Pro ($ 3 USD)</span>
              <span className="font-semibold text-foreground tabular-nums">
                {formatNumberAR(metrics.planCounts.pro_3usd)}
              </span>
            </div>
          </CardContent>
        </Card>

        <Card className="karrito-card-elevation rounded-3xl border border-border bg-card">
          <CardHeader className="flex flex-row items-start justify-between gap-2 pb-2">
            <div className="flex flex-col gap-1">
              <CardDescription className="text-[13px] font-semibold">
                Cargas con IA hoy
              </CardDescription>
              <CardTitle className="text-3xl font-extrabold tracking-tight tabular-nums">
                {formatNumberAR(metrics.aiLoadsToday)}
              </CardTitle>
            </div>
            <div className="flex size-10 items-center justify-center rounded-2xl bg-accent text-accent-foreground">
              <SparklesIcon className="size-5" aria-hidden="true" />
            </div>
          </CardHeader>
          <CardContent className="flex flex-col gap-1 pt-1 text-xs text-muted-foreground">
            <span>
              Fecha de Argentina (UTC-3):{" "}
              <strong className="font-semibold text-foreground">
                {formatDateAR(metrics.todayArgentinaISO)}
              </strong>
            </span>
            <span>Suma de usos registrados en el día en curso.</span>
          </CardContent>
        </Card>

        <Card className="karrito-card-elevation rounded-3xl border border-border bg-card">
          <CardHeader className="flex flex-row items-start justify-between gap-2 pb-2">
            <div className="flex flex-col gap-1">
              <CardDescription className="text-[13px] font-semibold">
                Facturación mensual estimada
              </CardDescription>
              <CardTitle className="text-3xl font-extrabold tracking-tight text-success tabular-nums">
                {formatUsdAR(metrics.estimatedMonthlyRevenueUsd)}
              </CardTitle>
            </div>
            <div className="flex size-10 items-center justify-center rounded-2xl bg-brand-lime text-brand-lime-foreground">
              <CoinsIcon className="size-5" aria-hidden="true" />
            </div>
          </CardHeader>
          <CardContent className="flex flex-col gap-1 pt-1 text-xs text-muted-foreground">
            <div className="flex items-center justify-between">
              <span>Plan Básico ($ 3 USD)</span>
              <span className="font-semibold text-foreground tabular-nums">
                {formatNumberAR(metrics.activeBannerAdsCount)} activos
              </span>
            </div>
            <div className="flex items-center justify-between">
              <span>Plan Destacado ($ 5 USD)</span>
              <span className="font-semibold text-foreground tabular-nums">
                {formatNumberAR(metrics.activeFeaturedAdsCount)} activos
              </span>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <Card className="karrito-card-elevation rounded-3xl border border-border bg-card">
          <CardHeader>
            <CardTitle className="text-base font-bold">
              Anuncios activos por localidad
            </CardTitle>
            <CardDescription>
              Comercios vigentes que se muestran hoy en la app gratuita (sin
              contar pausados ni vencidos).
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-col gap-3">
            <div className="flex flex-wrap gap-2">
              {activeAdsByCity.map(({ city, count }) => (
                <div
                  key={city}
                  className="flex items-center gap-2 rounded-full border border-border bg-field px-3.5 py-2 text-sm"
                >
                  <span className="font-semibold text-foreground">{city}</span>
                  <Badge
                    variant={count > 0 ? "default" : "secondary"}
                    className="tabular-nums"
                  >
                    {formatNumberAR(count)}
                  </Badge>
                </div>
              ))}
            </div>
            <div className="flex flex-wrap gap-2 pt-2">
              <Button
                type="button"
                onClick={onOpenNewAd}
                className="min-h-[42px] rounded-full px-5"
              >
                Cargar anuncio
              </Button>
              <Button
                type="button"
                variant="outline"
                onClick={() => onNavigateTab("publicidad")}
                className="min-h-[42px] rounded-full px-5"
              >
                Ver comercios
                <ArrowRightIcon data-icon="inline-end" />
              </Button>
            </div>
          </CardContent>
        </Card>

        <Card className="karrito-card-elevation rounded-3xl border border-border bg-card">
          <CardHeader>
            <CardTitle className="text-base font-bold">
              Accesos directos de gestión
            </CardTitle>
            <CardDescription>
              Atajos para administrar cuentas de usuarios y los límites de
              Karrito sin volver a compilar la app.
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-col gap-2.5">
            <Button
              type="button"
              variant="outline"
              onClick={() => onNavigateTab("usuarios")}
              className="min-h-[48px] w-full justify-between rounded-2xl px-4"
            >
              <span className="flex items-center gap-2.5">
                <UsersIcon className="size-4 text-primary" />
                Cambiar planes o suspender usuarios
              </span>
              <ArrowRightIcon className="size-4 text-muted-foreground" />
            </Button>

            <Button
              type="button"
              variant="outline"
              onClick={() => onNavigateTab("configuracion")}
              className="min-h-[48px] w-full justify-between rounded-2xl px-4"
            >
              <span className="flex items-center gap-2.5">
                <SlidersHorizontalIcon className="size-4 text-primary" />
                Ajustar topes de IA y listas activas
              </span>
              <ArrowRightIcon className="size-4 text-muted-foreground" />
            </Button>
          </CardContent>
        </Card>
      </div>
    </section>
  );
}
