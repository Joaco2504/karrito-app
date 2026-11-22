"use client";

import * as React from "react";
import { MoonIcon, SunIcon } from "lucide-react";
import { Button } from "@/components/ui/button";

type StoredScheme = "light" | "dark" | null;
type ResolvedScheme = "light" | "dark";

const SCHEME_CHANGE_EVENT = "karrito:color-scheme-change";

function readStoredScheme(): StoredScheme {
  if (typeof window === "undefined") return null;
  try {
    const value = window.localStorage.getItem("color-scheme");
    if (value === "light" || value === "dark") return value;
    return null;
  } catch {
    return null;
  }
}

function getSystemScheme(): ResolvedScheme {
  if (typeof window === "undefined") return "light";
  return window.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light";
}

function applySchemeToDocument(stored: StoredScheme): ResolvedScheme {
  const effective = stored ?? getSystemScheme();

  const meta = document.querySelector<HTMLMetaElement>(
    'meta[name="color-scheme"]',
  );
  if (meta) {
    meta.content = stored ?? "light dark";
  }

  document.documentElement.classList.toggle("dark", effective === "dark");
  document.documentElement.classList.toggle("light", stored === "light");
  return effective;
}

function getClientSchemeSnapshot(): ResolvedScheme {
  const stored = readStoredScheme();
  return stored ?? getSystemScheme();
}

function getServerSchemeSnapshot(): ResolvedScheme {
  return "light";
}

function subscribeToScheme(callback: () => void): () => void {
  if (typeof window === "undefined") return () => {};

  const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");

  const handleMediaChange = () => {
    // Nunca borra el valor guardado si coincide con el sistema; solo sincroniza el DOM.
    applySchemeToDocument(readStoredScheme());
    callback();
  };

  const handleStorage = (event: StorageEvent) => {
    if (event.key === "color-scheme") {
      applySchemeToDocument(readStoredScheme());
      callback();
    }
  };

  const handleCustomChange = () => {
    callback();
  };

  mediaQuery.addEventListener("change", handleMediaChange);
  window.addEventListener("storage", handleStorage);
  window.addEventListener(SCHEME_CHANGE_EVENT, handleCustomChange);

  return () => {
    mediaQuery.removeEventListener("change", handleMediaChange);
    window.removeEventListener("storage", handleStorage);
    window.removeEventListener(SCHEME_CHANGE_EVENT, handleCustomChange);
  };
}

export function ThemeToggle() {
  const renderedScheme = React.useSyncExternalStore(
    subscribeToScheme,
    getClientSchemeSnapshot,
    getServerSchemeSnapshot,
  );

  const handleToggle = () => {
    const system = getSystemScheme();
    const currentEffective = readStoredScheme() ?? system;
    const target: ResolvedScheme =
      currentEffective === "dark" ? "light" : "dark";

    const nextStored: StoredScheme = target === system ? null : target;
    try {
      if (nextStored === null) {
        window.localStorage.removeItem("color-scheme");
      } else {
        window.localStorage.setItem("color-scheme", nextStored);
      }
    } catch {
      // Si el almacenamiento está bloqueado, igualmente aplicamos el cambio en la sesión actual.
    }

    applySchemeToDocument(nextStored);
    window.dispatchEvent(new Event(SCHEME_CHANGE_EVENT));
  };

  const isDark = renderedScheme === "dark";
  const label = isDark ? "Cambiar a modo claro" : "Cambiar a modo oscuro";

  return (
    <Button
      type="button"
      variant="outline"
      size="icon"
      onClick={handleToggle}
      aria-label={label}
      title={label}
      className="size-10 rounded-full"
    >
      {isDark ? <SunIcon className="size-4" /> : <MoonIcon className="size-4" />}
    </Button>
  );
}
