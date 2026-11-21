"use client";

import * as React from "react";
import { CheckCircle2Icon, RotateCcwIcon, SaveIcon } from "lucide-react";
import { toast } from "sonner";
import { saveAppConfigAction } from "@/app/actions/admin-actions";
import {
  APP_CONFIG_FIELDS,
  formatDateAR,
  type AppConfigKey,
} from "@/lib/constants/karrito";
import type { AppConfigRow } from "@/lib/types/database";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Field,
  FieldDescription,
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { Spinner } from "@/components/ui/spinner";

interface ConfigSectionProps {
  configRows: AppConfigRow[];
  onDataChanged: () => void;
}

function buildConfigMap(rows: AppConfigRow[]): Record<AppConfigKey, string> {
  const rowMap = new Map(rows.map((row) => [row.key, row.value]));
  return {
    free_daily_ai_limit:
      rowMap.get("free_daily_ai_limit") ??
      String(APP_CONFIG_FIELDS[0].defaultValue),
    free_max_lists:
      rowMap.get("free_max_lists") ?? String(APP_CONFIG_FIELDS[1].defaultValue),
    basic_max_lists:
      rowMap.get("basic_max_lists") ??
      String(APP_CONFIG_FIELDS[2].defaultValue),
    pro_max_lists:
      rowMap.get("pro_max_lists") ?? String(APP_CONFIG_FIELDS[3].defaultValue),
  };
}

export function ConfigSection({
  configRows,
  onDataChanged,
}: ConfigSectionProps) {
  const [savedRows, setSavedRows] = React.useState<AppConfigRow[]>(configRows);
  const [prevConfigRows, setPrevConfigRows] =
    React.useState<AppConfigRow[]>(configRows);
  const [draftOverrides, setDraftOverrides] = React.useState<
    Partial<Record<AppConfigKey, string>>
  >({});
  const [isSaving, setIsSaving] = React.useState(false);
  const [saveMessage, setSaveMessage] = React.useState<string | null>(null);
  const [errorMessage, setErrorMessage] = React.useState<string | null>(null);

  if (configRows !== prevConfigRows) {
    setPrevConfigRows(configRows);
    setSavedRows(configRows);
  }

  const savedValues = React.useMemo(
    () => buildConfigMap(savedRows),
    [savedRows],
  );

  const currentValues: Record<AppConfigKey, string> = {
    free_daily_ai_limit:
      draftOverrides.free_daily_ai_limit ?? savedValues.free_daily_ai_limit,
    free_max_lists:
      draftOverrides.free_max_lists ?? savedValues.free_max_lists,
    basic_max_lists:
      draftOverrides.basic_max_lists ?? savedValues.basic_max_lists,
    pro_max_lists: draftOverrides.pro_max_lists ?? savedValues.pro_max_lists,
  };

  const isDirty = APP_CONFIG_FIELDS.some(
    (field) => currentValues[field.key] !== savedValues[field.key],
  );

  const lastUpdated = React.useMemo(() => {
    let latest = "";
    for (const row of savedRows) {
      if (row.updated_at && row.updated_at > latest) {
        latest = row.updated_at;
      }
    }
    return latest;
  }, [savedRows]);

  const handleFieldChange = (key: AppConfigKey, value: string) => {
    setSaveMessage(null);
    setErrorMessage(null);
    setDraftOverrides((prev) => ({ ...prev, [key]: value }));
  };

  const handleReset = () => {
    setDraftOverrides({});
    setSaveMessage(null);
    setErrorMessage(null);
  };

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setSaveMessage(null);
    setErrorMessage(null);

    const numericValues = {} as Record<AppConfigKey, number>;
    for (const field of APP_CONFIG_FIELDS) {
      const parsed = Number.parseInt(currentValues[field.key].trim(), 10);
      if (
        !Number.isInteger(parsed) ||
        parsed < field.min ||
        parsed > field.max
      ) {
        setErrorMessage(
          `Ingresá un número entero entre ${field.min} y ${field.max} en «${field.label}».`,
        );
        return;
      }
      numericValues[field.key] = parsed;
    }

    setIsSaving(true);
    try {
      const result = await saveAppConfigAction(numericValues);
      if (!result.ok || !result.data) {
        setErrorMessage(result.message);
        toast.error(result.message);
        return;
      }

      setSavedRows(result.data);
      setDraftOverrides({});
      setSaveMessage(result.message);
      toast.success(result.message);
      onDataChanged();
    } catch {
      const msg =
        "No pudimos guardar la configuración por un error de conexión. Probá de nuevo.";
      setErrorMessage(msg);
      toast.error(msg);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <section
      aria-label="Control remoto de configuración"
      className="flex flex-col gap-5"
    >
      <Card className="max-w-2xl rounded-2xl border border-border bg-card shadow-xs">
        <CardHeader>
          <CardTitle className="text-lg font-semibold">
            Control remoto de configuración
          </CardTitle>
          <CardDescription>
            Ajustá los límites de IA y listas activas guardados en
            karrito.app_config. Los cambios impactan en la app sin actualizar el
            APK.
            {lastUpdated
              ? ` Última actualización: ${formatDateAR(lastUpdated)}.`
              : ""}
          </CardDescription>
        </CardHeader>

        <form onSubmit={handleSubmit}>
          <CardContent className="flex flex-col gap-5">
            {errorMessage && (
              <Alert variant="destructive">
                <AlertTitle>No pudimos guardar los cambios</AlertTitle>
                <AlertDescription>{errorMessage}</AlertDescription>
              </Alert>
            )}

            {saveMessage && (
              <Alert className="border-success/40 bg-success/10 text-foreground">
                <CheckCircle2Icon className="size-4 text-success" />
                <AlertTitle>Cambios aplicados</AlertTitle>
                <AlertDescription>{saveMessage}</AlertDescription>
              </Alert>
            )}

            <FieldGroup>
              {APP_CONFIG_FIELDS.map((field) => (
                <Field key={field.key}>
                  <FieldLabel htmlFor={`cfg-${field.key}`}>
                    {field.label}
                  </FieldLabel>
                  <FieldDescription>{field.help}</FieldDescription>
                  <Input
                    id={`cfg-${field.key}`}
                    type="number"
                    inputMode="numeric"
                    min={field.min}
                    max={field.max}
                    step={1}
                    required
                    value={currentValues[field.key]}
                    onChange={(event) =>
                      handleFieldChange(field.key, event.target.value)
                    }
                  />
                </Field>
              ))}
            </FieldGroup>
          </CardContent>

          <CardFooter className="mt-6 flex flex-wrap items-center justify-between gap-3 border-t border-border pt-4">
            <Button
              type="button"
              variant="outline"
              disabled={!isDirty || isSaving}
              onClick={handleReset}
              className="min-h-[44px] rounded-[12px]"
            >
              <RotateCcwIcon data-icon="inline-start" />
              Descartar cambios
            </Button>

            <Button
              type="submit"
              disabled={!isDirty || isSaving}
              className="min-h-[44px] rounded-[12px] px-5"
            >
              {isSaving ? (
                <>
                  <Spinner data-icon="inline-start" />
                  Guardando...
                </>
              ) : (
                <>
                  <SaveIcon data-icon="inline-start" />
                  Guardar configuración
                </>
              )}
            </Button>
          </CardFooter>
        </form>
      </Card>
    </section>
  );
}
