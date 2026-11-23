"use client";

import * as React from "react";
import {
  CheckIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  CopyIcon,
  UsersIcon,
  XIcon,
} from "lucide-react";
import { toast } from "sonner";
import {
  fetchUsersPageAction,
  toggleUserBannedAction,
  updateUserPlanAction,
} from "@/app/actions/admin-actions";
import {
  PLAN_TIERS,
  USER_CITIES,
  formatDateAR,
  formatNumberAR,
} from "@/lib/constants/karrito";
import type { PlanTier, UserProfileRow } from "@/lib/types/database";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Empty,
  EmptyContent,
  EmptyDescription,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from "@/components/ui/empty";
import { Field, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

const PLAN_FILTER_ITEMS = [
  { label: "Todos los planes", value: "__all__" },
  { label: PLAN_TIERS.free.label, value: "free" },
  { label: PLAN_TIERS.basic_2usd.label, value: "basic_2usd" },
  { label: PLAN_TIERS.pro_3usd.label, value: "pro_3usd" },
];

const USER_PLAN_ITEMS: Array<{ label: string; value: PlanTier }> = [
  { label: PLAN_TIERS.free.shortLabel, value: "free" },
  { label: PLAN_TIERS.basic_2usd.shortLabel, value: "basic_2usd" },
  { label: PLAN_TIERS.pro_3usd.shortLabel, value: "pro_3usd" },
];

const PAGE_SIZE = 50;

interface UsersSectionProps {
  users: UserProfileRow[];
  totalCount: number;
  todayArgentinaISO: string;
  currentAdminUserId: string;
  onDataChanged: () => void;
}

export function UsersSection({
  users: initialUsers,
  totalCount: initialTotalCount,
  todayArgentinaISO,
  currentAdminUserId,
  onDataChanged,
}: UsersSectionProps) {
  const [prevInitialUsers, setPrevInitialUsers] =
    React.useState<UserProfileRow[]>(initialUsers);
  const [users, setUsers] = React.useState<UserProfileRow[]>(initialUsers);
  const [totalCount, setTotalCount] = React.useState<number>(initialTotalCount);
  const [page, setPage] = React.useState<number>(1);
  const [isLoadingPage, setIsLoadingPage] = React.useState<boolean>(false);

  if (initialUsers !== prevInitialUsers) {
    setPrevInitialUsers(initialUsers);
    setUsers(initialUsers);
    setTotalCount(initialTotalCount);
    setPage(1);
  }
  const [searchQuery, setSearchQuery] = React.useState("");
  const [planFilter, setPlanFilter] = React.useState<string>("__all__");
  const [cityFilter, setCityFilter] = React.useState<string>("__all__");
  const [busyUserId, setBusyUserId] = React.useState<string | null>(null);
  const [copiedId, setCopiedId] = React.useState<string | null>(null);

  const loadPage = React.useCallback(
    async (
      targetPage: number,
      nextSearch: string,
      nextPlan: string,
      nextCity: string,
    ) => {
      setIsLoadingPage(true);
      const result = await fetchUsersPageAction({
        page: targetPage,
        search: nextSearch,
        plan: nextPlan,
        city: nextCity,
      });
      setIsLoadingPage(false);
      if (!result.ok || !result.data) {
        toast.error(result.message);
        return;
      }
      setUsers(result.data.rows);
      setTotalCount(result.data.totalCount);
      setPage(result.data.page);
    },
    [],
  );

  const cityFilterItems = React.useMemo(() => {
    const citySet = new Set<string>(USER_CITIES);
    for (const user of users) {
      if (user.city && user.city.trim()) {
        citySet.add(user.city.trim());
      }
    }
    return [
      { label: "Todas las localidades", value: "__all__" },
      ...Array.from(citySet).map((city) => ({ label: city, value: city })),
    ];
  }, [users]);

  const filteredUsers = React.useMemo(() => {
    const query = searchQuery.trim().toLowerCase();
    return users.filter((user) => {
      if (planFilter !== "__all__" && user.plan_tier !== planFilter) {
        return false;
      }
      if (cityFilter !== "__all__" && user.city !== cityFilter) {
        return false;
      }
      if (query) {
        const emailMatch = (user.email ?? "").toLowerCase().includes(query);
        const idMatch = user.id.toLowerCase().includes(query);
        return emailMatch || idMatch;
      }
      return true;
    });
  }, [users, searchQuery, planFilter, cityFilter]);

  const totalPages = Math.max(1, Math.ceil(totalCount / PAGE_SIZE));

  const hasActiveFilters =
    searchQuery.trim() !== "" ||
    planFilter !== "__all__" ||
    cityFilter !== "__all__";

  const handleResetFilters = () => {
    setSearchQuery("");
    setPlanFilter("__all__");
    setCityFilter("__all__");
    void loadPage(1, "", "__all__", "__all__");
  };

  const handlePlanChange = async (user: UserProfileRow, nextPlan: PlanTier) => {
    if (user.plan_tier === nextPlan) return;
    setBusyUserId(user.id);
    setUsers((prev) =>
      prev.map((item) =>
        item.id === user.id ? { ...item, plan_tier: nextPlan } : item,
      ),
    );

    const result = await updateUserPlanAction(user.id, nextPlan);
    setBusyUserId(null);

    if (!result.ok || !result.data) {
      setUsers((prev) =>
        prev.map((item) =>
          item.id === user.id ? { ...item, plan_tier: user.plan_tier } : item,
        ),
      );
      toast.error(result.message);
      return;
    }

    setUsers((prev) =>
      prev.map((item) => (item.id === user.id ? result.data! : item)),
    );
    toast.success(
      `Plan cambiado a ${PLAN_TIERS[nextPlan].shortLabel} para ${user.email ?? "cuenta invitada"}.`,
    );
    onDataChanged();
  };

  const handleToggleEnabled = async (
    user: UserProfileRow,
    nextEnabled: boolean,
  ) => {
    const nextBanned = !nextEnabled;
    setBusyUserId(user.id);
    setUsers((prev) =>
      prev.map((item) =>
        item.id === user.id ? { ...item, is_banned: nextBanned } : item,
      ),
    );

    const result = await toggleUserBannedAction(user.id, nextBanned);
    setBusyUserId(null);

    if (!result.ok || !result.data) {
      setUsers((prev) =>
        prev.map((item) =>
          item.id === user.id ? { ...item, is_banned: user.is_banned } : item,
        ),
      );
      toast.error(result.message);
      return;
    }

    setUsers((prev) =>
      prev.map((item) => (item.id === user.id ? result.data! : item)),
    );
    toast.success(result.message);
    onDataChanged();
  };

  const handleCopyUuid = async (uuid: string) => {
    try {
      await navigator.clipboard.writeText(uuid);
      setCopiedId(uuid);
      toast.success("UUID copiado.");
      window.setTimeout(() => {
        setCopiedId((current) => (current === uuid ? null : current));
      }, 1800);
    } catch {
      toast.error("No pudimos copiar el UUID al portapapeles.");
    }
  };

  return (
    <section aria-label="Gestión de usuarios" className="flex flex-col gap-5">
      <Card className="karrito-card-elevation rounded-3xl border border-border bg-card">
        <CardHeader className="flex flex-col gap-4">
          <div className="flex flex-col gap-1">
            <CardTitle className="text-lg font-semibold">
              Gestión de usuarios
            </CardTitle>
            <CardDescription>
              Buscá cuentas por correo o UUID, asigná planes manualmente y
              habilitá o suspendé el acceso a Karrito.
            </CardDescription>
          </div>

          <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
            <Field>
              <FieldLabel htmlFor="users-search">
                Buscar por correo o UUID
              </FieldLabel>
              <Input
                id="users-search"
                type="search"
                value={searchQuery}
                onChange={(event) => setSearchQuery(event.target.value)}
                placeholder="Ej: nombre@gmail.com o 67056666..."
              />
            </Field>

            <Field>
              <FieldLabel htmlFor="users-plan-filter">Plan</FieldLabel>
              <Select
                items={PLAN_FILTER_ITEMS}
                value={planFilter}
                onValueChange={(nextValue) => {
                  if (nextValue) {
                    setPlanFilter(nextValue);
                    void loadPage(1, searchQuery, nextValue, cityFilter);
                  }
                }}
              >
                <SelectTrigger id="users-plan-filter">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectGroup>
                    {PLAN_FILTER_ITEMS.map((item) => (
                      <SelectItem key={item.value} value={item.value}>
                        {item.label}
                      </SelectItem>
                    ))}
                  </SelectGroup>
                </SelectContent>
              </Select>
            </Field>

            <Field>
              <FieldLabel htmlFor="users-city-filter">Localidad</FieldLabel>
              <Select
                items={cityFilterItems}
                value={cityFilter}
                onValueChange={(nextValue) => {
                  if (nextValue) {
                    setCityFilter(nextValue);
                    void loadPage(1, searchQuery, planFilter, nextValue);
                  }
                }}
              >
                <SelectTrigger id="users-city-filter">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectGroup>
                    {cityFilterItems.map((item) => (
                      <SelectItem key={item.value} value={item.value}>
                        {item.label}
                      </SelectItem>
                    ))}
                  </SelectGroup>
                </SelectContent>
              </Select>
            </Field>
          </div>

          {hasActiveFilters && (
            <div className="flex items-center justify-between gap-2 text-xs text-muted-foreground">
              <span>
                Mostrando {formatNumberAR(filteredUsers.length)} de{" "}
                {formatNumberAR(users.length)} cuentas.
              </span>
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={handleResetFilters}
                className="rounded-[10px]"
              >
                <XIcon data-icon="inline-start" />
                Limpiar filtros
              </Button>
            </div>
          )}
        </CardHeader>

        <CardContent>
          {filteredUsers.length === 0 ? (
            <Empty className="rounded-xl border border-dashed border-border py-10">
              <EmptyHeader>
                <EmptyMedia variant="icon">
                  <UsersIcon className="size-5" />
                </EmptyMedia>
                <EmptyTitle>No encontramos cuentas con esos filtros</EmptyTitle>
                <EmptyDescription>
                  Probá borrar el texto de búsqueda o cambiar el filtro de plan
                  y localidad.
                </EmptyDescription>
              </EmptyHeader>
              {hasActiveFilters && (
                <EmptyContent>
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handleResetFilters}
                    className="rounded-[12px]"
                  >
                    Limpiar filtros
                  </Button>
                </EmptyContent>
              )}
            </Empty>
          ) : (
            <Table wrapperLabel="Tabla de cuentas registradas en Karrito">
              <TableCaption>
                Página {formatNumberAR(page)} de {formatNumberAR(totalPages)} ·
                Mostrando {formatNumberAR(filteredUsers.length)} de{" "}
                {formatNumberAR(totalCount)} cuentas en karrito.users_profile.
              </TableCaption>
              <TableHeader>
                <TableRow>
                  <TableHead>Cuenta y UUID</TableHead>
                  <TableHead>Localidad</TableHead>
                  <TableHead className="text-right">Cargas IA hoy</TableHead>
                  <TableHead>Plan asignado</TableHead>
                  <TableHead>Acceso</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredUsers.map((user) => {
                  const usedToday =
                    user.last_ai_date === todayArgentinaISO
                      ? user.daily_ai_count
                      : 0;
                  const isBusy = busyUserId === user.id;
                  const isOwnAdmin = user.id === currentAdminUserId;
                  const isCopied = copiedId === user.id;

                  return (
                    <TableRow key={user.id}>
                      <TableCell className="min-w-[240px]">
                        <div className="flex flex-col gap-1">
                          <div className="flex items-center gap-2">
                            {user.email ? (
                              <span className="font-medium text-foreground">
                                {user.email}
                              </span>
                            ) : (
                              <Badge variant="secondary">
                                Invitado anónimo
                              </Badge>
                            )}
                            {isOwnAdmin && (
                              <Badge variant="outline">Tu cuenta</Badge>
                            )}
                          </div>
                          <div className="flex items-center gap-1.5 font-mono text-xs text-muted-foreground">
                            <span>
                              {user.id.slice(0, 8)}...{user.id.slice(-6)}
                            </span>
                            <Button
                              type="button"
                              variant="ghost"
                              size="icon-xs"
                              aria-label={`Copiar UUID de ${user.email ?? "invitado"}`}
                              title="Copiar UUID completo"
                              onClick={() => handleCopyUuid(user.id)}
                            >
                              {isCopied ? (
                                <CheckIcon className="size-3 text-success" />
                              ) : (
                                <CopyIcon className="size-3" />
                              )}
                            </Button>
                          </div>
                        </div>
                      </TableCell>

                      <TableCell>{user.city}</TableCell>

                      <TableCell className="text-right">
                        <div className="flex flex-col items-end">
                          <span className="font-medium tabular-nums">
                            {formatNumberAR(usedToday)}
                          </span>
                          <span className="text-xs text-muted-foreground">
                            Último uso: {formatDateAR(user.last_ai_date)}
                          </span>
                        </div>
                      </TableCell>

                      <TableCell className="min-w-[190px]">
                        <Select
                          items={USER_PLAN_ITEMS}
                          value={user.plan_tier}
                          disabled={isBusy}
                          onValueChange={(nextValue) => {
                            if (
                              nextValue === "free" ||
                              nextValue === "basic_2usd" ||
                              nextValue === "pro_3usd"
                            ) {
                              handlePlanChange(user, nextValue);
                            }
                          }}
                        >
                          <SelectTrigger
                            size="sm"
                            aria-label={`Plan de ${user.email ?? user.id}`}
                          >
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectGroup>
                              {USER_PLAN_ITEMS.map((item) => (
                                <SelectItem key={item.value} value={item.value}>
                                  {item.label}
                                </SelectItem>
                              ))}
                            </SelectGroup>
                          </SelectContent>
                        </Select>
                      </TableCell>

                      <TableCell className="min-w-[175px]">
                        <div className="flex items-center gap-2.5">
                          <Switch
                            checked={!user.is_banned}
                            disabled={isBusy || isOwnAdmin}
                            aria-label={
                              user.is_banned
                                ? `Habilitar cuenta de ${user.email ?? user.id}`
                                : `Suspender cuenta de ${user.email ?? user.id}`
                            }
                            onCheckedChange={(checked) =>
                              handleToggleEnabled(user, checked)
                            }
                          />
                          {user.is_banned ? (
                            <Badge variant="destructive">Suspendida</Badge>
                          ) : (
                            <span className="text-xs font-medium text-success">
                              Habilitada
                            </span>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          )}

          {totalPages > 1 && (
            <div className="mt-4 flex flex-wrap items-center justify-between gap-3 border-t border-border pt-4 text-sm">
              <span className="text-muted-foreground">
                Página {formatNumberAR(page)} de {formatNumberAR(totalPages)} (
                {formatNumberAR(totalCount)} cuentas, {PAGE_SIZE} por página)
              </span>
              <div className="flex items-center gap-2">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  disabled={page <= 1 || isLoadingPage}
                  onClick={() =>
                    void loadPage(page - 1, searchQuery, planFilter, cityFilter)
                  }
                  className="rounded-full"
                >
                  <ChevronLeftIcon data-icon="inline-start" />
                  Anterior
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  disabled={page >= totalPages || isLoadingPage}
                  onClick={() =>
                    void loadPage(page + 1, searchQuery, planFilter, cityFilter)
                  }
                  className="rounded-full"
                >
                  Siguiente
                  <ChevronRightIcon data-icon="inline-end" />
                </Button>
              </div>
            </div>
          )}
        </CardContent>
      </Card>
    </section>
  );
}
