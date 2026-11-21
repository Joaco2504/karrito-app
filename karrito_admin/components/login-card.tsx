"use client";

import * as React from "react";
import Link from "next/link";
import { ShieldAlertIcon, ShoppingCartIcon } from "lucide-react";
import { createBrowserSupabaseClient } from "@/lib/supabase/client";
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
import { Spinner } from "@/components/ui/spinner";

interface LoginCardProps {
  errorCode?: string;
}

function getErrorCopy(errorCode?: string): {
  title: string;
  description: string;
} | null {
  switch (errorCode) {
    case "acceso_denegado":
      return {
        title: "Acceso denegado",
        description:
          "La cuenta de Google con la que intentaste entrar no está autorizada para administrar Karrito. Cerramos esa sesión por seguridad. Elegí la cuenta administradora para ingresar.",
      };
    case "auth_error":
      return {
        title: "No pudimos validar tu ingreso",
        description:
          "El inicio de sesión con Google se interrumpió antes de completarse. Volvé a tocar Entrar con Google e intentá de nuevo.",
      };
    case "config_error":
      return {
        title: "Falta configuración del servidor",
        description:
          "Las variables de entorno de Supabase no están cargadas en el servidor. Revisá la configuración antes de iniciar sesión.",
      };
    default:
      return null;
  }
}

export function LoginCard({ errorCode }: LoginCardProps) {
  const [isPending, setIsPending] = React.useState(false);
  const [clientError, setClientError] = React.useState<string | null>(null);

  const serverError = getErrorCopy(errorCode);

  const handleGoogleLogin = async () => {
    setClientError(null);
    setIsPending(true);
    try {
      const supabase = createBrowserSupabaseClient();
      const redirectTo = `${window.location.origin}/auth/callback`;
      const { error } = await supabase.auth.signInWithOAuth({
        provider: "google",
        options: {
          redirectTo,
          queryParams: {
            prompt: "select_account",
          },
        },
      });
      if (error) {
        setClientError(
          "No pudimos abrir el inicio de sesión con Google porque el servidor rechazó la solicitud. Revisá tu conexión y probá de nuevo.",
        );
        setIsPending(false);
      }
    } catch {
      setClientError(
        "No pudimos conectarnos con el servicio de autenticación. Revisá tu señal e intentá otra vez.",
      );
      setIsPending(false);
    }
  };

  return (
    <Card className="w-full max-w-md rounded-2xl border border-border bg-card shadow-sm">
      <CardHeader className="gap-3">
        <div className="flex items-center gap-3">
          <div className="flex size-11 items-center justify-center rounded-xl bg-brand-accent text-brand-accent-foreground">
            <ShoppingCartIcon className="size-5" aria-hidden="true" />
          </div>
          <div className="flex flex-col">
            <CardTitle className="text-xl font-semibold">
              Panel de Karrito
            </CardTitle>
            <CardDescription>
              Ingreso restringido para administración
            </CardDescription>
          </div>
        </div>
      </CardHeader>

      <CardContent className="flex flex-col gap-4">
        {serverError && (
          <Alert variant="destructive">
            <ShieldAlertIcon className="size-4" />
            <AlertTitle>{serverError.title}</AlertTitle>
            <AlertDescription>{serverError.description}</AlertDescription>
          </Alert>
        )}

        {clientError && (
          <Alert variant="destructive">
            <ShieldAlertIcon className="size-4" />
            <AlertTitle>No pudimos iniciar sesión</AlertTitle>
            <AlertDescription>{clientError}</AlertDescription>
          </Alert>
        )}

        <p className="text-sm leading-relaxed text-muted-foreground">
          Usá la cuenta de Google habilitada en Karrito para consultar métricas,
          cargar anuncios de comercios de Catamarca y ajustar límites de la app.
        </p>

        <Button
          type="button"
          onClick={handleGoogleLogin}
          disabled={isPending}
          className="min-h-[48px] w-full rounded-[14px] text-sm font-medium"
        >
          {isPending ? (
            <>
              <Spinner data-icon="inline-start" />
              Abriendo Google...
            </>
          ) : (
            <>
              <svg
                aria-hidden="true"
                viewBox="0 0 24 24"
                className="size-4"
                data-icon="inline-start"
              >
                <path
                  fill="currentColor"
                  d="M21.8 12.23c0-.72-.06-1.41-.18-2.08H12v3.94h5.5a4.7 4.7 0 0 1-2.04 3.09v2.56h3.3c1.93-1.78 3.04-4.4 3.04-7.51Z"
                />
                <path
                  fill="currentColor"
                  d="M12 22c2.76 0 5.07-.91 6.76-2.47l-3.3-2.56c-.91.61-2.08.98-3.46.98-2.66 0-4.91-1.8-5.72-4.21H2.87v2.64A10.22 10.22 0 0 0 12 22Z"
                />
                <path
                  fill="currentColor"
                  d="M6.28 13.74a6.13 6.13 0 0 1 0-3.48V7.62H2.87a10.22 10.22 0 0 0 0 8.76l3.41-2.64Z"
                />
                <path
                  fill="currentColor"
                  d="M12 6.05c1.5 0 2.85.52 3.91 1.53l2.93-2.93C17.06 2.99 14.75 2 12 2a10.22 10.22 0 0 0-9.13 5.62l3.41 2.64c.81-2.41 3.06-4.21 5.72-4.21Z"
                />
              </svg>
              Entrar con Google
            </>
          )}
        </Button>
      </CardContent>

      <CardFooter className="flex items-center justify-between border-t border-border pt-4 text-xs text-muted-foreground">
        <span>Acceso exclusivo para cuentas autorizadas</span>
        <Link
          href="/privacidad"
          className="font-medium text-primary underline-offset-4 hover:underline"
        >
          Política de privacidad
        </Link>
      </CardFooter>
    </Card>
  );
}
