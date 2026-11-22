"use client";

import * as React from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  BarChart3Icon,
  LogOutIcon,
  MegaphoneIcon,
  RefreshCwIcon,
  ShieldCheckIcon,
  ShoppingCartIcon,
  SlidersHorizontalIcon,
  UsersIcon,
} from "lucide-react";
import { signOutAdminAction } from "@/app/actions/admin-actions";
import type { AdminDashboardData } from "@/lib/data/dashboard";
import { formatNumberAR } from "@/lib/constants/karrito";
import { ConfigSection } from "@/components/admin/config-section";
import { LocalAdsSection } from "@/components/admin/local-ads-section";
import {
  MetricsSection,
  type AdminTabKey,
} from "@/components/admin/metrics-section";
import { UsersSection } from "@/components/admin/users-section";
import { ThemeToggle } from "@/components/theme-toggle";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

interface AdminShellProps {
  adminEmail: string;
  adminUserId: string;
  data: AdminDashboardData;
}

export function AdminShell({
  adminEmail,
  adminUserId,
  data,
}: AdminShellProps) {
  const router = useRouter();
  const [activeTab, setActiveTab] = React.useState<AdminTabKey>("resumen");
  const [adDialogOpen, setAdDialogOpen] = React.useState(false);
  const [isRefreshing, startRefreshTransition] = React.useTransition();

  const handleRefresh = () => {
    startRefreshTransition(() => {
      router.refresh();
    });
  };

  const handleOpenNewAd = () => {
    setActiveTab("publicidad");
    setAdDialogOpen(true);
  };

  return (
    <div className="flex min-h-screen flex-col bg-background text-foreground">
      <header className="sticky top-0 z-20 border-b border-border bg-card/95 backdrop-blur-xs">
        <div className="mx-auto flex w-full max-w-7xl flex-wrap items-center justify-between gap-3 px-4 py-3.5 sm:px-6">
          <div className="flex items-center gap-3">
            <div className="flex size-10 items-center justify-center rounded-2xl bg-brand-accent text-brand-lime">
              <ShoppingCartIcon className="size-5" aria-hidden="true" />
            </div>
            <div className="flex flex-col">
              <h1 className="text-base font-extrabold leading-tight tracking-tight text-foreground">
                Karrito
              </h1>
              <span className="text-xs text-muted-foreground">
                Panel de administración · {adminEmail}
              </span>
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-2">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={handleRefresh}
              disabled={isRefreshing}
              className="min-h-[40px] rounded-full px-4"
            >
              <RefreshCwIcon
                data-icon="inline-start"
                className={isRefreshing ? "animate-spin" : undefined}
              />
              Actualizar
            </Button>

            <Button
              variant="outline"
              size="sm"
              render={<Link href="/privacidad" />}
              nativeButton={false}
              className="min-h-[40px] rounded-full px-4"
            >
              <ShieldCheckIcon data-icon="inline-start" />
              Privacidad
            </Button>

            <ThemeToggle />

            <form action={signOutAdminAction}>
              <Button
                type="submit"
                variant="outline"
                size="sm"
                className="min-h-[40px] rounded-full px-4"
              >
                <LogOutIcon data-icon="inline-start" />
                Salir
              </Button>
            </form>
          </div>
        </div>
      </header>

      <main className="mx-auto flex w-full max-w-7xl flex-1 flex-col gap-6 px-4 py-6 sm:px-6">
        <Tabs
          value={activeTab}
          onValueChange={(nextValue) => {
            if (
              nextValue === "resumen" ||
              nextValue === "publicidad" ||
              nextValue === "usuarios" ||
              nextValue === "configuracion"
            ) {
              setActiveTab(nextValue);
            }
          }}
          className="flex flex-col gap-6"
        >
          <div className="overflow-x-auto pb-1">
            <TabsList className="karrito-card-elevation h-auto w-full justify-start gap-1.5 rounded-full border border-border bg-card p-1.5 sm:w-fit">
              <TabsTrigger
                value="resumen"
                className="min-h-[40px] rounded-full px-4 font-bold data-active:bg-brand-accent data-active:text-brand-accent-foreground"
              >
                <BarChart3Icon data-icon="inline-start" />
                Métricas
              </TabsTrigger>

              <TabsTrigger
                value="publicidad"
                className="min-h-[40px] rounded-full px-4 font-bold data-active:bg-brand-accent data-active:text-brand-accent-foreground"
              >
                <MegaphoneIcon data-icon="inline-start" />
                Publicidad local
                <Badge
                  variant="secondary"
                  className="ml-1 tabular-nums"
                >
                  {formatNumberAR(data.ads.length)}
                </Badge>
              </TabsTrigger>

              <TabsTrigger
                value="usuarios"
                className="min-h-[40px] rounded-full px-4 font-bold data-active:bg-brand-accent data-active:text-brand-accent-foreground"
              >
                <UsersIcon data-icon="inline-start" />
                Usuarios
                <Badge
                  variant="secondary"
                  className="ml-1 tabular-nums"
                >
                  {formatNumberAR(data.users.length)}
                </Badge>
              </TabsTrigger>

              <TabsTrigger
                value="configuracion"
                className="min-h-[40px] rounded-full px-4 font-bold data-active:bg-brand-accent data-active:text-brand-accent-foreground"
              >
                <SlidersHorizontalIcon data-icon="inline-start" />
                Configuración
              </TabsTrigger>
            </TabsList>
          </div>

          <TabsContent value="resumen">
            <MetricsSection
              metrics={data.metrics}
              ads={data.ads}
              onNavigateTab={setActiveTab}
              onOpenNewAd={handleOpenNewAd}
            />
          </TabsContent>

          <TabsContent value="publicidad">
            <LocalAdsSection
              ads={data.ads}
              dialogOpen={adDialogOpen}
              onDialogOpenChange={setAdDialogOpen}
              onDataChanged={handleRefresh}
            />
          </TabsContent>

          <TabsContent value="usuarios">
            <UsersSection
              users={data.users}
              todayArgentinaISO={data.metrics.todayArgentinaISO}
              currentAdminUserId={adminUserId}
              onDataChanged={handleRefresh}
            />
          </TabsContent>

          <TabsContent value="configuracion">
            <ConfigSection
              configRows={data.config}
              onDataChanged={handleRefresh}
            />
          </TabsContent>
        </Tabs>
      </main>
    </div>
  );
}
