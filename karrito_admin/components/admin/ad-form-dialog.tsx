"use client";

import * as React from "react";
import Image from "next/image";
import { ImagePlusIcon, Trash2Icon } from "lucide-react";
import { toast } from "sonner";
import { saveLocalAdAction } from "@/app/actions/admin-actions";
import {
  AD_TIERS,
  LOCAL_AD_CITIES,
  extractArgentinaDateInput,
  getDefaultAdExpiryDateISO,
} from "@/lib/constants/karrito";
import type { AdTier, LocalAdRow } from "@/lib/types/database";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Field,
  FieldContent,
  FieldDescription,
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field";
import { Input } from "@/components/ui/input";
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

const CITY_ITEMS = LOCAL_AD_CITIES.map((city) => ({
  label: city,
  value: city,
}));

const TIER_ITEMS: Array<{ label: string; value: AdTier }> = [
  {
    label: AD_TIERS.banner_3usd.label,
    value: "banner_3usd",
  },
  {
    label: AD_TIERS.featured_5usd.label,
    value: "featured_5usd",
  },
];

interface AdFormDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  editingAd: LocalAdRow | null;
  onSaved: (ad: LocalAdRow) => void;
}

export function AdFormDialog({
  open,
  onOpenChange,
  editingAd,
  onSaved,
}: AdFormDialogProps) {
  const [businessName, setBusinessName] = React.useState(
    () => editingAd?.business_name ?? "",
  );
  const [city, setCity] = React.useState<string>(
    () => editingAd?.city ?? "Andalgalá",
  );
  const [tier, setTier] = React.useState<AdTier>(
    () => editingAd?.tier ?? "banner_3usd",
  );
  const [bannerUrl, setBannerUrl] = React.useState(
    () => editingAd?.banner_url ?? "",
  );
  const [interstitialUrl, setInterstitialUrl] = React.useState(
    () => editingAd?.interstitial_url ?? "",
  );
  const [actionUrl, setActionUrl] = React.useState(
    () => editingAd?.action_url ?? "",
  );
  const [expiresDate, setExpiresDate] = React.useState(() =>
    editingAd
      ? extractArgentinaDateInput(editingAd.expires_at)
      : getDefaultAdExpiryDateISO(30),
  );
  const [isActive, setIsActive] = React.useState(
    () => editingAd?.is_active ?? true,
  );

  const [uploadingSlot, setUploadingSlot] = React.useState<
    "banner" | "interstitial" | null
  >(null);
  const [isSaving, setIsSaving] = React.useState(false);
  const [formError, setFormError] = React.useState<string | null>(null);

  const bannerInputRef = React.useRef<HTMLInputElement>(null);
  const interstitialInputRef = React.useRef<HTMLInputElement>(null);

  const handleUploadImage = async (
    file: File | undefined,
    slot: "banner" | "interstitial",
  ) => {
    if (!file) return;
    setFormError(null);
    setUploadingSlot(slot);

    try {
      const formData = new FormData();
      formData.append("file", file);
      formData.append("slot", slot);
      formData.append("businessName", businessName || "comercio");

      const response = await fetch("/api/ads/upload", {
        method: "POST",
        body: formData,
      });

      const payload = (await response.json()) as {
        ok?: boolean;
        url?: string;
        error?: string;
      };

      if (!response.ok || !payload.ok || !payload.url) {
        setFormError(
          payload.error ??
            "No pudimos subir la imagen al bucket ads-media. Revisá el archivo e intentá de nuevo.",
        );
        return;
      }

      if (slot === "banner") {
        setBannerUrl(payload.url);
        toast.success("Imagen de banner subida.");
      } else {
        setInterstitialUrl(payload.url);
        toast.success("Imagen intersticial subida.");
      }
    } catch {
      setFormError(
        "No pudimos conectarnos para subir la imagen. Revisá tu señal y volvé a intentar.",
      );
    } finally {
      setUploadingSlot(null);
      if (slot === "banner" && bannerInputRef.current) {
        bannerInputRef.current.value = "";
      }
      if (slot === "interstitial" && interstitialInputRef.current) {
        interstitialInputRef.current.value = "";
      }
    }
  };

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setFormError(null);
    setIsSaving(true);

    try {
      const result = await saveLocalAdAction({
        id: editingAd?.id,
        business_name: businessName,
        city,
        tier,
        banner_url: bannerUrl,
        interstitial_url: interstitialUrl,
        action_url: actionUrl,
        expires_date: expiresDate,
        is_active: isActive,
      });

      if (!result.ok || !result.data) {
        setFormError(result.message);
        return;
      }

      toast.success(result.message);
      onSaved(result.data);
      onOpenChange(false);
    } catch {
      setFormError(
        "No pudimos guardar el anuncio por un problema de conexión. Probá de nuevo en unos segundos.",
      );
    } finally {
      setIsSaving(false);
    }
  };

  const isEditMode = Boolean(editingAd);
  const isUploading = uploadingSlot !== null;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-xl">
        <DialogHeader>
          <DialogTitle>
            {isEditMode ? "Editar anuncio local" : "Nuevo anuncio local"}
          </DialogTitle>
          <DialogDescription>
            {isEditMode
              ? "Actualizá los datos, las piezas gráficas o el vencimiento del comercio."
              : "Cargá un comercio local para mostrar su banner o intersticial en la app gratuita."}
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="flex flex-col gap-5">
          {formError && (
            <Alert variant="destructive">
              <AlertDescription>{formError}</AlertDescription>
            </Alert>
          )}

          <FieldGroup>
            <Field>
              <FieldLabel htmlFor="ad-business-name">
                Nombre del comercio
              </FieldLabel>
              <Input
                id="ad-business-name"
                value={businessName}
                onChange={(event) => setBusinessName(event.target.value)}
                placeholder="Ej: Supermercado El Sol"
                required
                minLength={2}
                maxLength={120}
              />
            </Field>

            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Field>
                <FieldLabel htmlFor="ad-city">Localidad</FieldLabel>
                <Select
                  items={CITY_ITEMS}
                  value={city}
                  onValueChange={(nextValue) => {
                    if (nextValue) setCity(nextValue);
                  }}
                >
                  <SelectTrigger id="ad-city">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectGroup>
                      {CITY_ITEMS.map((item) => (
                        <SelectItem key={item.value} value={item.value}>
                          {item.label}
                        </SelectItem>
                      ))}
                    </SelectGroup>
                  </SelectContent>
                </Select>
              </Field>

              <Field>
                <FieldLabel htmlFor="ad-expires">
                  Fecha de vencimiento
                </FieldLabel>
                <Input
                  id="ad-expires"
                  type="date"
                  value={expiresDate}
                  onChange={(event) => setExpiresDate(event.target.value)}
                  required
                />
              </Field>
            </div>

            <Field>
              <FieldLabel htmlFor="ad-tier">Plan publicitario</FieldLabel>
              <FieldDescription>
                {AD_TIERS[tier].description}
              </FieldDescription>
              <Select
                items={TIER_ITEMS}
                value={tier}
                onValueChange={(nextValue) => {
                  if (
                    nextValue === "banner_3usd" ||
                    nextValue === "featured_5usd"
                  ) {
                    setTier(nextValue);
                  }
                }}
              >
                <SelectTrigger id="ad-tier">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectGroup>
                    {TIER_ITEMS.map((item) => (
                      <SelectItem key={item.value} value={item.value}>
                        {item.label}
                      </SelectItem>
                    ))}
                  </SelectGroup>
                </SelectContent>
              </Select>
            </Field>

            <Field>
              <FieldLabel htmlFor="ad-banner-upload">
                Imagen de banner (320 x 50 px recomendado)
              </FieldLabel>
              <FieldDescription>
                Se sube directo al bucket ads-media. Formatos aceptados: JPG,
                PNG o WebP hasta 5 MB.
              </FieldDescription>
              <input
                ref={bannerInputRef}
                id="ad-banner-upload"
                type="file"
                accept="image/png,image/jpeg,image/webp,image/gif"
                className="sr-only"
                onChange={(event) =>
                  handleUploadImage(event.target.files?.[0], "banner")
                }
                disabled={isUploading || isSaving}
              />

              {bannerUrl ? (
                <div className="flex flex-col gap-3 rounded-[14px] border border-border bg-field p-3">
                  <div className="flex items-center justify-center overflow-hidden rounded-lg border border-border bg-card p-2">
                    <Image
                      src={bannerUrl}
                      alt={`Vista previa del banner de ${businessName || "comercio"}`}
                      width={320}
                      height={50}
                      unoptimized
                      className="h-[50px] w-full max-w-[320px] rounded object-cover"
                    />
                  </div>
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      disabled={isUploading || isSaving}
                      onClick={() => bannerInputRef.current?.click()}
                      className="rounded-[10px]"
                    >
                      {uploadingSlot === "banner" ? (
                        <>
                          <Spinner data-icon="inline-start" />
                          Subiendo...
                        </>
                      ) : (
                        <>
                          <ImagePlusIcon data-icon="inline-start" />
                          Cambiar banner
                        </>
                      )}
                    </Button>
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      disabled={isUploading || isSaving}
                      onClick={() => setBannerUrl("")}
                      className="rounded-[10px] text-destructive hover:text-destructive"
                    >
                      <Trash2Icon data-icon="inline-start" />
                      Quitar
                    </Button>
                  </div>
                </div>
              ) : (
                <Button
                  type="button"
                  variant="outline"
                  disabled={isUploading || isSaving}
                  onClick={() => bannerInputRef.current?.click()}
                  className="min-h-[48px] w-full justify-center rounded-[14px] border-dashed bg-field"
                >
                  {uploadingSlot === "banner" ? (
                    <>
                      <Spinner data-icon="inline-start" />
                      Subiendo banner...
                    </>
                  ) : (
                    <>
                      <ImagePlusIcon data-icon="inline-start" />
                      Subir imagen de banner (320 x 50 px)
                    </>
                  )}
                </Button>
              )}
            </Field>

            {tier === "featured_5usd" && (
              <Field>
                <FieldLabel htmlFor="ad-interstitial-upload">
                  Imagen intersticial (1080 x 1920 px recomendado)
                </FieldLabel>
                <FieldDescription>
                  Pantalla vertical completa para el Plan Comercio Local
                  Destacado ($ 5 USD/mes).
                </FieldDescription>
                <input
                  ref={interstitialInputRef}
                  id="ad-interstitial-upload"
                  type="file"
                  accept="image/png,image/jpeg,image/webp,image/gif"
                  className="sr-only"
                  onChange={(event) =>
                    handleUploadImage(event.target.files?.[0], "interstitial")
                  }
                  disabled={isUploading || isSaving}
                />

                {interstitialUrl ? (
                  <div className="flex flex-col gap-3 rounded-[14px] border border-border bg-field p-3">
                    <div className="flex items-center justify-center overflow-hidden rounded-lg border border-border bg-card p-2">
                      <Image
                        src={interstitialUrl}
                        alt={`Vista previa del intersticial de ${businessName || "comercio"}`}
                        width={162}
                        height={288}
                        unoptimized
                        className="h-56 w-auto rounded object-contain"
                      />
                    </div>
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        disabled={isUploading || isSaving}
                        onClick={() => interstitialInputRef.current?.click()}
                        className="rounded-[10px]"
                      >
                        {uploadingSlot === "interstitial" ? (
                          <>
                            <Spinner data-icon="inline-start" />
                            Subiendo...
                          </>
                        ) : (
                          <>
                            <ImagePlusIcon data-icon="inline-start" />
                            Cambiar intersticial
                          </>
                        )}
                      </Button>
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        disabled={isUploading || isSaving}
                        onClick={() => setInterstitialUrl("")}
                        className="rounded-[10px] text-destructive hover:text-destructive"
                      >
                        <Trash2Icon data-icon="inline-start" />
                        Quitar
                      </Button>
                    </div>
                  </div>
                ) : (
                  <Button
                    type="button"
                    variant="outline"
                    disabled={isUploading || isSaving}
                    onClick={() => interstitialInputRef.current?.click()}
                    className="min-h-[48px] w-full justify-center rounded-[14px] border-dashed bg-field"
                  >
                    {uploadingSlot === "interstitial" ? (
                      <>
                        <Spinner data-icon="inline-start" />
                        Subiendo intersticial...
                      </>
                    ) : (
                      <>
                        <ImagePlusIcon data-icon="inline-start" />
                        Subir imagen intersticial (1080 x 1920 px)
                      </>
                    )}
                  </Button>
                )}
              </Field>
            )}

            <Field>
              <FieldLabel htmlFor="ad-action-url">
                Enlace de destino (WhatsApp o Google Maps)
              </FieldLabel>
              <FieldDescription>
                Formato: https://wa.me/5493835123456 o enlace de ubicación en
                Google Maps.
              </FieldDescription>
              <Input
                id="ad-action-url"
                type="url"
                value={actionUrl}
                onChange={(event) => setActionUrl(event.target.value)}
                placeholder="https://wa.me/5493835..."
                required
              />
            </Field>

            <Field
              orientation="horizontal"
              className="rounded-2xl border border-border bg-field px-4 py-3"
            >
              <FieldContent>
                <FieldLabel
                  htmlFor="ad-is-active"
                  className="text-sm font-semibold text-foreground"
                >
                  Anuncio activo en la app
                </FieldLabel>
                <FieldDescription>
                  Si lo desactivás, queda pausado sin borrar sus impresiones ni
                  clics.
                </FieldDescription>
              </FieldContent>
              <Switch
                id="ad-is-active"
                checked={isActive}
                onCheckedChange={(checked) => setIsActive(checked)}
              />
            </Field>
          </FieldGroup>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              disabled={isSaving || isUploading}
              onClick={() => onOpenChange(false)}
              className="min-h-[44px] rounded-full px-5"
            >
              Cancelar
            </Button>
            <Button
              type="submit"
              disabled={isSaving || isUploading}
              className="min-h-[44px] rounded-full px-6"
            >
              {isSaving ? (
                <>
                  <Spinner data-icon="inline-start" />
                  Guardando...
                </>
              ) : isEditMode ? (
                "Guardar cambios"
              ) : (
                "Crear anuncio"
              )}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
