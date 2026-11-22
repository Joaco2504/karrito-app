import type { Metadata } from "next";
import { Geist_Mono, Plus_Jakarta_Sans, Space_Grotesk } from "next/font/google";
import { Toaster } from "@/components/ui/sonner";
import "./globals.css";

const plusJakartaSans = Plus_Jakarta_Sans({
  variable: "--font-sans",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700", "800"],
});

const spaceGrotesk = Space_Grotesk({
  variable: "--font-heading",
  subsets: ["latin"],
  weight: ["500", "600", "700"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Karrito | Panel de administración",
  description:
    "Panel interno de Karrito para gestionar métricas, publicidad local de Catamarca, usuarios y configuración remota.",
};

const COLOR_SCHEME_INIT_SCRIPT = `(function(){try{var s=localStorage.getItem("color-scheme");var m=document.querySelector('meta[name="color-scheme"]');if(m){m.content=(s==="light"||s==="dark")?s:"light dark";}var isDark=s==="dark"||(s!=="light"&&window.matchMedia("(prefers-color-scheme: dark)").matches);document.documentElement.classList.toggle("dark",isDark);document.documentElement.classList.toggle("light",s==="light");}catch(e){}})();`;

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="es-AR"
      suppressHydrationWarning
      className={`${plusJakartaSans.variable} ${spaceGrotesk.variable} ${geistMono.variable} h-full antialiased`}
    >
      <head>
        <meta name="color-scheme" content="light dark" />
        <script
          dangerouslySetInnerHTML={{ __html: COLOR_SCHEME_INIT_SCRIPT }}
        />
      </head>
      <body className="min-h-full flex flex-col bg-background text-foreground">
        {children}
        <Toaster position="bottom-right" richColors />
      </body>
    </html>
  );
}
