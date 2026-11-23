"use client";

import * as React from "react";
import Image from "next/image";
import {
  CheckIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  CopyIcon,
  ExternalLinkIcon,
  MegaphoneIcon,
  PencilIcon,
  PlusIcon,
  Trash2Icon,
} from "lucide-react";
import { toast } from "sonner";
import {
  deleteLocalAdAction,
  fetchLocalAdsPageAction,
  toggleLocalAdActiveAction,
} from "@/app/actions/admin-actions";
import {
  AD_TIERS,
  LOCAL_AD_CITIES,
  calculateCtr,
  formatDateAR,
  formatNumberAR,
  formatPercentAR,
  isAdExpired,
} from "@/lib/constants/karrito";
import { isSafeHttpsUrl } from "@/lib/security/url";
import type { LocalAdRow } from "@/lib/types/database";
import { AdFormDialog } from "@/components/admin/ad-form-dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
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
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Spinner } from "@/components/ui/spinner";
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

const CITY_FILTER_ITEMS = [
  { label: "Todas las localidades", value: "__all__" },
  ...LOCAL_AD_CITIES.map((city) => ({ label: city, value: city })),
];

const PAGE_SIZE = 50;

interface LocalAdsSectionProps {
  ads: LocalAdRow[];
  totalCount: number;
  dialogOpen: boolean;
  onDialogOpenChange: (open: boolean) => void;
  onDataChanged: () => void;
}

function buildWhatsappReport(ad: LocalAdRow): string {
  const ctr = formatPercentAR(calculateCtr(ad.clicks, ad.impressions));
  const expired = isAdExpired(ad.expires_at);
  const statusLabel = expired
    ? "Vencido"
    : ad.is_active
      ? "Activo"
      : "Pausado";

  return [
    `Hola, te paso el reporte de tu anuncio en Karrito:`,
    `Comercio: ${ad.business_name} (${ad.city})`,
    `Plan: ${AD_TIERS[ad.tier].label}`,
    `Impresiones mostradas: ${formatNumberAR(ad.impressions)}`,
    `Clics al enlace: ${formatNumberAR(ad.clicks)}`,
    `Porcentaje de clics (CTR): ${ctr}`,
    `Vencimiento: ${formatDateAR(ad.expires_at)}`,
    `Estado actual: ${statusLabel}`,
  ].join("\n");
}

export function LocalAdsSection({
  ads: initialAds,
  totalCount: initialTotalCount,
  dialogOpen,
  onDialogOpenChange,
  onDataChanged,
}: LocalAdsSectionProps) {
  const [prevInitialAds, setPrevInitialAds] =
    React.useState<LocalAdRow[]>(initialAds);
  const [ads, setAds] = React.useState<LocalAdRow[]>(initialAds);
  const [totalCount, setTotalCount] = React.useState<number>(initialTotalCount);
  const [page, setPage] = React.useState<number>(1);
  const [isLoadingPage, setIsLoadingPage] = React.useState<boolean>(false);

  if (initialAds !== prevInitialAds) {
    setPrevInitialAds(initialAds);
    setAds(initialAds);
    setTotalCount(initialTotalCount);
    setPage(1);
  }
  const [cityFilter, setCityFilter] = React.useState<string>("__all__");
  const [editingAd, setEditingAd] = React.useState<LocalAdRow | null>(null);
  const [deletingAd, setDeletingAd] = React.useState<LocalAdRow | null>(null);
  const [isDeleting, setIsDeleting] = React.useState(false);
  const [busyAdId, setBusyAdId] = React.useState<string | null>(null);
  const [copiedAdId, setCopiedAdId] = React.useState<string | null>(null);

  const loadPage = React.useCallback(
    async (targetPage: number, nextCity: string) => {
      setIsLoadingPage(true);
      const result = await fetchLocalAdsPageAction({
        page: targetPage,
        city: nextCity,
      });
      setIsLoadingPage(false);
      if (!result.ok || !result.data) {
        toast.error(result.message);
        return;
      }
      setAds(result.data.rows);
      setTotalCount(result.data.totalCount);
      setPage(result.data.page);
    },
    [],
  );

  const filteredAds = React.useMemo(() => {
    if (cityFilter === "__all__") return ads;
    return ads.filter((ad) => ad.city === cityFilter);
  }, [ads, cityFilter]);

  const totalPages = Math.max(1, Math.ceil(totalCount / PAGE_SIZE));

  const handleOpenCreate = () => {
    setEditingAd(null);
    onDialogOpenChange(true);
  };

  const handleOpenEdit = (ad: LocalAdRow) => {
    setEditingAd(ad);
    onDialogOpenChange(true);
  };

  const handleAdSaved = (savedAd: LocalAdRow) => {
    setAds((prev) => {
      const exists = prev.some((item) => item.id === savedAd.id);
      if (exists) {
        return prev.map((item) => (item.id === savedAd.id ? savedAd : item));
      }
      return [savedAd, ...prev];
    });
    onDataChanged();
  };

  const handleToggleActive = async (ad: LocalAdRow, nextActive: boolean) => {
    setBusyAdId(ad.id);
    setAds((prev) =>
      prev.map((item) =>
        item.id === ad.id ? { ...item, is_active: nextActive } : item,
      ),
    );

    const result = await toggleLocalAdActiveAction(ad.id, nextActive);
    setBusyAdId(null);

    if (!result.ok || !result.data) {
      setAds((prev) =>
        prev.map((item) =>
          item.id === ad.id ? { ...item, is_active: ad.is_active } : item,
        ),
      );
      toast.error(result.message);
      return;
    }

    setAds((prev) =>
      prev.map((item) => (item.id === ad.id ? result.data! : item)),
    );
    toast.success(result.message);
    onDataChanged();
  };

  const handleConfirmDelete = async () => {
    if (!deletingAd) return;
    setIsDeleting(true);
    const result = await deleteLocalAdAction(deletingAd.id);
    setIsDeleting(false);

    if (!result.ok) {
      toast.error(result.message);
      return;
    }

    setAds((prev) => prev.filter((item) => item.id !== deletingAd.id));
    setDeletingAd(null);
    toast.success(result.message);
    onDataChanged();
  };

  const handleCopyReport = async (ad: LocalAdRow) => {
    const report = buildWhatsappReport(ad);
    try {
      await navigator.clipboard.writeText(report);
      setCopiedAdId(ad.id);
      toast.success(`Reporte de ${ad.business_name} copiado para WhatsApp.`);
      window.setTimeout(() => {
        setCopiedAdId((current) => (current === ad.id ? null : current));
      }, 2200);
    } catch {
      toast.error(
        "El navegador bloqueó el portapapeles. Probá dar permiso de copia o abrir el panel con HTTPS.",
      );
    }
  };

  return (
    <section
      aria-label="Gestor de publicidad local"
      className="flex flex-col gap-5"
    >
      <Card className="karrito-card-elevation rounded-3xl border border-border bg-card">
        <CardHeader className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div className="flex flex-col gap-1">
            <CardTitle className="text-lg font-semibold">
              Publicidad local
            </CardTitle>
            <CardDescription>
              Administrá los comercios de Catamarca que pautan en la versión
              gratuita de Karrito.
            </CardDescription>
          </div>

          <div className="flex flex-col gap-3 sm:flex-row sm:items-end">
            <Field className="w-full sm:w-56">
              <FieldLabel htmlFor="ads-city-filter">
                Filtrar por localidad
              </FieldLabel>
              <Select
                items={CITY_FILTER_ITEMS}
                value={cityFilter}
                onValueChange={(nextValue) => {
                  if (nextValue) {
                    setCityFilter(nextValue);
                    void loadPage(1, nextValue);
                  }
                }}
              >
                <SelectTrigger id="ads-city-filter">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectGroup>
                    {CITY_FILTER_ITEMS.map((item) => (
                      <SelectItem key={item.value} value={item.value}>
                        {item.label}
                      </SelectItem>
                    ))}
                  </SelectGroup>
                </SelectContent>
              </Select>
            </Field>

            <Button
              type="button"
              onClick={handleOpenCreate}
              className="min-h-[48px] rounded-full px-6"
            >
              <PlusIcon data-icon="inline-start" />
              Nuevo anuncio
            </Button>
          </div>
        </CardHeader>

        <CardContent>
          {filteredAds.length === 0 ? (
            <Empty className="rounded-xl border border-dashed border-border py-10">
              <EmptyHeader>
                <EmptyMedia variant="icon">
                  <MegaphoneIcon className="size-5" />
                </EmptyMedia>
                <EmptyTitle>
                  {cityFilter === "__all__"
                    ? "Todavía no cargaste ningún anuncio local"
                    : `No hay anuncios cargados en ${cityFilter}`}
                </EmptyTitle>
                <EmptyDescription>
                  Tocá Nuevo anuncio para subir el banner de un comercio y
                  activar su pauta en la app.
                </EmptyDescription>
              </EmptyHeader>
              <EmptyContent>
                <Button
                  type="button"
                  onClick={handleOpenCreate}
                  className="min-h-[44px] rounded-[12px]"
                >
                  <PlusIcon data-icon="inline-start" />
                  Nuevo anuncio
                </Button>
              </EmptyContent>
            </Empty>
          ) : (
            <Table wrapperLabel="Tabla de comercios con publicidad local">
              <TableCaption>
                Página {formatNumberAR(page)} de {formatNumberAR(totalPages)} ·
                Mostrando {formatNumberAR(filteredAds.length)} de{" "}
                {formatNumberAR(totalCount)} anuncios cargados.
              </TableCaption>
              <TableHeader>
                <TableRow>
                  <TableHead>Comercio</TableHead>
                  <TableHead>Localidad</TableHead>
                  <TableHead>Plan</TableHead>
                  <TableHead className="text-right">Impresiones</TableHead>
                  <TableHead className="text-right">Clics</TableHead>
                  <TableHead className="text-right">CTR</TableHead>
                  <TableHead>Vencimiento</TableHead>
                  <TableHead>Estado</TableHead>
                  <TableHead className="text-right">Acciones</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredAds.map((ad) => {
                  const expired = isAdExpired(ad.expires_at);
                  const ctr = calculateCtr(ad.clicks, ad.impressions);
                  const isBusy = busyAdId === ad.id;
                  const isCopied = copiedAdId === ad.id;

                  return (
                    <TableRow key={ad.id}>
                      <TableCell className="min-w-[230px]">
                        <div className="flex items-center gap-3">
                          {ad.banner_url ? (
                            <Image
                              src={ad.banner_url}
                              alt={`Banner de ${ad.business_name}`}
                              width={96}
                              height={32}
                              unoptimized
                              className="h-8 w-20 shrink-0 rounded-md border border-border bg-field object-cover"
                            />
                          ) : (
                            <div className="flex h-8 w-20 shrink-0 items-center justify-center rounded-md border border-border bg-field text-xs text-muted-foreground">
                              Sin foto
                            </div>
                          )}
                          <div className="flex min-w-0 flex-col">
                            <span className="truncate font-medium text-foreground">
                              {ad.business_name}
                            </span>
                            {isSafeHttpsUrl(ad.action_url) ? (
                              <a
                                href={ad.action_url}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="inline-flex items-center gap-1 text-xs text-muted-foreground hover:text-primary hover:underline"
                              >
                                Abrir enlace
                                <ExternalLinkIcon className="size-3" />
                              </a>
                            ) : (
                              <span className="text-xs text-destructive">
                                Enlace bloqueado (no HTTPS)
                              </span>
                            )}
                          </div>
                        </div>
                      </TableCell>

                      <TableCell>{ad.city}</TableCell>

                      <TableCell>
                        <Badge
                          variant={
                            ad.tier === "featured_5usd" ? "default" : "secondary"
                          }
                        >
                          {AD_TIERS[ad.tier].shortLabel}
                        </Badge>
                      </TableCell>

                      <TableCell className="text-right tabular-nums">
                        {formatNumberAR(ad.impressions)}
                      </TableCell>

                      <TableCell className="text-right tabular-nums">
                        {formatNumberAR(ad.clicks)}
                      </TableCell>

                      <TableCell className="text-right font-medium tabular-nums">
                        {formatPercentAR(ctr)}
                      </TableCell>

                      <TableCell>
                        <div className="flex items-center gap-2">
                          <span className="tabular-nums">
                            {formatDateAR(ad.expires_at)}
                          </span>
                          {expired && (
                            <Badge variant="destructive">Vencido</Badge>
                          )}
                        </div>
                      </TableCell>

                      <TableCell>
                        <div className="flex items-center gap-2.5">
                          <Switch
                            checked={ad.is_active}
                            disabled={isBusy}
                            aria-label={
                              ad.is_active
                                ? `Pausar anuncio de ${ad.business_name}`
                                : `Activar anuncio de ${ad.business_name}`
                            }
                            onCheckedChange={(checked) =>
                              handleToggleActive(ad, checked)
                            }
                          />
                          <span className="text-xs font-medium text-muted-foreground">
                            {ad.is_active ? "Activo" : "Pausado"}
                          </span>
                        </div>
                      </TableCell>

                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-1.5">
                          <Button
                            type="button"
                            variant="outline"
                            size="sm"
                            onClick={() => handleCopyReport(ad)}
                            className="rounded-[10px]"
                          >
                            {isCopied ? (
                              <>
                                <CheckIcon
                                  data-icon="inline-start"
                                  className="text-success"
                                />
                                Copiado
                              </>
                            ) : (
                              <>
                                <CopyIcon data-icon="inline-start" />
                                Copiar reporte para WhatsApp
                              </>
                            )}
                          </Button>

                          <Button
                            type="button"
                            variant="outline"
                            size="icon-sm"
                            aria-label={`Editar anuncio de ${ad.business_name}`}
                            title="Editar anuncio"
                            onClick={() => handleOpenEdit(ad)}
                            className="rounded-[10px]"
                          >
                            <PencilIcon className="size-3.5" />
                          </Button>

                          <Button
                            type="button"
                            variant="destructive"
                            size="icon-sm"
                            aria-label={`Borrar anuncio de ${ad.business_name}`}
                            title="Borrar anuncio"
                            onClick={() => setDeletingAd(ad)}
                            className="rounded-[10px]"
                          >
                            <Trash2Icon className="size-3.5" />
                          </Button>
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
                {formatNumberAR(totalCount)} anuncios, {PAGE_SIZE} por página)
              </span>
              <div className="flex items-center gap-2">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  disabled={page <= 1 || isLoadingPage}
                  onClick={() => void loadPage(page - 1, cityFilter)}
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
                  onClick={() => void loadPage(page + 1, cityFilter)}
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

      <AdFormDialog
        key={`${editingAd?.id ?? "new"}-${dialogOpen ? "open" : "closed"}`}
        open={dialogOpen}
        onOpenChange={(nextOpen) => {
          onDialogOpenChange(nextOpen);
          if (!nextOpen) setEditingAd(null);
        }}
        editingAd={editingAd}
        onSaved={handleAdSaved}
      />

      <AlertDialog
        open={Boolean(deletingAd)}
        onOpenChange={(open) => {
          if (!open && !isDeleting) setDeletingAd(null);
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>¿Borrar este anuncio local?</AlertDialogTitle>
            <AlertDialogDescription>
              Vas a borrar el anuncio de{" "}
              <strong className="font-medium text-foreground">
                {deletingAd?.business_name}
              </strong>
              . Se pierden sus métricas de impresiones y clics y sus imágenes
              subidas, y no se puede deshacer.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel autoFocus disabled={isDeleting}>
              Cancelar
            </AlertDialogCancel>
            <AlertDialogAction
              variant="destructive"
              disabled={isDeleting}
              onClick={handleConfirmDelete}
            >
              {isDeleting ? (
                <>
                  <Spinner data-icon="inline-start" />
                  Borrando...
                </>
              ) : (
                "Borrar anuncio"
              )}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </section>
  );
}
