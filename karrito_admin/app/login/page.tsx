import type { Metadata } from "next";
import { LoginCard } from "@/components/login-card";
import { ThemeToggle } from "@/components/theme-toggle";

export const metadata: Metadata = {
  title: "Iniciar sesión | Panel de Karrito",
  description:
    "Ingresá con tu cuenta de Google autorizada para administrar Karrito.",
};

interface LoginPageProps {
  searchParams: Promise<{ error?: string }>;
}

export default async function LoginPage({ searchParams }: LoginPageProps) {
  const params = await searchParams;

  return (
    <div className="flex min-h-screen flex-col bg-background">
      <header className="mx-auto flex w-full max-w-5xl items-center justify-end px-4 py-4 sm:px-6">
        <ThemeToggle />
      </header>
      <main className="flex flex-1 items-center justify-center px-4 pb-16">
        <LoginCard errorCode={params.error} />
      </main>
    </div>
  );
}
