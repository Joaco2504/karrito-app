import type { Metadata } from "next";
import Link from "next/link";
import { ArrowLeftIcon, ShoppingCartIcon } from "lucide-react";
import { ThemeToggle } from "@/components/theme-toggle";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";

export const metadata: Metadata = {
  title: "Política de privacidad | Karrito",
  description:
    "Cómo trata Karrito tus datos en Android: modo invitado anónimo, cuenta de Google, procesamiento temporal de voz y fotos, anuncios locales y eliminación de cuenta.",
};

export default function PrivacidadPage() {
  const contactEmail =
    process.env.NEXT_PUBLIC_ADMIN_EMAIL || "soporte@karrito.app";

  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="sticky top-0 z-10 border-b border-border bg-card/95 backdrop-blur-xs">
        <div className="mx-auto flex w-full max-w-3xl items-center justify-between gap-4 px-4 py-3.5 sm:px-6">
          <div className="flex items-center gap-2.5">
            <div className="flex size-9 items-center justify-center rounded-xl bg-primary text-primary-foreground">
              <ShoppingCartIcon className="size-4" aria-hidden="true" />
            </div>
            <div className="flex flex-col">
              <span className="text-sm font-semibold text-foreground">
                Karrito
              </span>
              <span className="text-xs text-muted-foreground">
                Política de privacidad
              </span>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              render={<Link href="/login" />}
              nativeButton={false}
              className="rounded-[12px]"
            >
              <ArrowLeftIcon data-icon="inline-start" />
              Panel admin
            </Button>
            <ThemeToggle />
          </div>
        </div>
      </header>

      <main className="mx-auto w-full max-w-3xl px-4 py-8 sm:px-6 sm:py-12">
        <Card className="rounded-2xl border border-border bg-card shadow-xs">
          <CardContent className="flex flex-col gap-6 p-6 sm:p-10">
            <div className="flex flex-col gap-2">
              <p className="text-xs font-medium text-muted-foreground">
                Última actualización: 21/11/2026
              </p>
              <h1 className="text-2xl font-semibold tracking-tight text-foreground sm:text-3xl">
                Política de privacidad de Karrito
              </h1>
              <p className="text-sm leading-relaxed text-muted-foreground">
                Karrito es una aplicación Android de listas de compras que
                ordena productos por comercio y pasillo, pensada para personas
                de Argentina y comercios locales de Catamarca (Andalgalá, Belén,
                Santa María y Saujil). Acá te contamos qué datos se usan, para
                qué sirven y cómo podés borrarlos por completo.
              </p>
            </div>

            <Separator />

            <section className="flex flex-col gap-2.5">
              <h2 className="text-lg font-semibold text-foreground">
                1. Modo invitado anónimo
              </h2>
              <p className="text-sm leading-relaxed text-foreground/90">
                Podés usar Karrito apenas la instalás, sin crear usuario ni dar
                tu correo. Al abrir la app por primera vez, el sistema genera un
                identificador técnico anónimo en Supabase para guardar tus
                listas locales, contar tus cargas diarias con IA en el plan
                gratuito y recordar los pasillos que corregís. Ese identificador
                no contiene tu nombre ni tu correo electrónico.
              </p>
            </section>

            <section className="flex flex-col gap-2.5">
              <h2 className="text-lg font-semibold text-foreground">
                2. Vinculación opcional con cuenta de Google
              </h2>
              <p className="text-sm leading-relaxed text-foreground/90">
                Si querés sincronizar tus listas entre varios teléfonos, guardar
                un respaldo en la nube o compartir listas en vivo, podés
                vincular tu cuenta de Google desde Ajustes. Cuando lo hacés,
                Karrito guarda tu correo electrónico y el identificador de tu
                cuenta para asociar tus listas, tu orden de pasillos y tus
                productos frecuentes. No leemos tus contactos, tus correos ni
                otros datos de Google.
              </p>
            </section>

            <section className="flex flex-col gap-2.5">
              <h2 className="text-lg font-semibold text-foreground">
                3. Procesamiento de texto, audio y fotos con IA
              </h2>
              <p className="text-sm leading-relaxed text-foreground/90">
                Cuando escribís o pegás una lista, el texto se envía de forma
                cifrada a nuestra función en Supabase y a la API de Google
                Gemini para separar cada producto y asignarle un comercio y un
                pasillo. En el plan Pro, cuando dictás una lista por voz (audio
                M4A) o sacás una foto de una lista escrita en papel (imagen
                JPEG), el archivo se transmite únicamente para extraer los
                productos en ese instante.
              </p>
              <p className="text-sm leading-relaxed text-foreground/90">
                Karrito no almacena de forma permanente tus grabaciones de audio
                ni las fotos de tus listas en papel, y desactiva el guardado de
                sesión en la consulta al modelo. Una vez que recibís los
                productos ordenados en tu teléfono, el audio o la imagen se
                descartan.
              </p>
            </section>

            <section className="flex flex-col gap-2.5">
              <h2 className="text-lg font-semibold text-foreground">
                4. Localidad elegida a mano, sin acceso al GPS
              </h2>
              <p className="text-sm leading-relaxed text-foreground/90">
                En la bienvenida o desde Ajustes elegís manualmente tu localidad
                (por ejemplo Andalgalá, Belén, Saujil o Santa María). Ese dato
                se usa solo para mostrarte avisos de comercios de tu ciudad en
                la versión gratuita. Karrito no pide permiso de ubicación y no
                accede al GPS de tu teléfono.
              </p>
            </section>

            <section className="flex flex-col gap-2.5">
              <h2 className="text-lg font-semibold text-foreground">
                5. Notificaciones push con Firebase Cloud Messaging
              </h2>
              <p className="text-sm leading-relaxed text-foreground/90">
                Karrito utiliza Firebase Cloud Messaging (Google) para enviar
                notificaciones relacionadas con el funcionamiento de la app y
                avisos relevantes de tus listas compartidas. Para eso se guarda
                un token técnico de notificación asociado a tu instalación.
                Podés desactivar las notificaciones en cualquier momento desde
                los ajustes de Android.
              </p>
            </section>

            <section className="flex flex-col gap-2.5">
              <h2 className="text-lg font-semibold text-foreground">
                6. Publicidad local y Google AdMob
              </h2>
              <p className="text-sm leading-relaxed text-foreground/90">
                La versión gratuita se sostiene mostrando anuncios de comercios
                de tu localidad y, cuando no hay pauta local disponible para esa
                ciudad, espacios publicitarios de Google AdMob. Para los
                anuncios locales contamos únicamente las impresiones y los clics
                totales de cada comercio, sin perfilar a cada persona. Google
                AdMob puede usar el identificador de publicidad de Android según
                su propia política y la configuración de privacidad de tu
                dispositivo. Los planes Básico y Pro eliminan todos los
                anuncios.
              </p>
            </section>

            <section className="flex flex-col gap-2.5">
              <h2 className="text-lg font-semibold text-foreground">
                7. Suscripciones con Google Play y RevenueCat
              </h2>
              <p className="text-sm leading-relaxed text-foreground/90">
                Las suscripciones mensuales del Plan Básico ($ 2 USD/mes) y del
                Plan Pro ($ 3 USD/mes) se procesan a través de Google Play.
                Utilizamos RevenueCat para comprobar si tu suscripción está
                activa, renovada o cancelada mediante tu identificador de
                usuario. Karrito nunca accede a los datos de tu tarjeta ni a tu
                información bancaria.
              </p>
            </section>

            <section className="flex flex-col gap-2.5">
              <h2 className="text-lg font-semibold text-foreground">
                8. Derecho de eliminación total de cuenta y datos
              </h2>
              <p className="text-sm leading-relaxed text-foreground/90">
                Podés pedir en cualquier momento que borremos tu cuenta y todos
                los datos guardados en la nube: tu correo vinculado, tus listas
                de compras, los ítems, los pasillos ordenados, los productos
                aprendidos y el token de notificaciones. Para solicitarlo,
                escribinos a{" "}
                <a
                  href={`mailto:${contactEmail}?subject=Solicitud%20de%20eliminaci%C3%B3n%20de%20cuenta%20Karrito`}
                  className="font-medium text-primary underline underline-offset-4"
                >
                  {contactEmail}
                </a>{" "}
                indicando el correo de Google que vinculaste en la app (o el ID
                de cuenta visible en Ajustes si usás modo invitado).
              </p>
              <p className="text-sm leading-relaxed text-foreground/90">
                Procesamos la baja completa en un plazo máximo de 7 días hábiles
                y te confirmamos por correo cuando los datos fueron eliminados
                de Supabase. Los datos que estén guardados únicamente en tu
                teléfono se borran al desinstalar Karrito o borrar el
                almacenamiento de la app desde Android.
              </p>
            </section>

            <Separator />

            <section className="flex flex-col gap-1.5 text-xs text-muted-foreground">
              <p>
                Responsable de Karrito y canal de contacto para consultas sobre
                privacidad:{" "}
                <a
                  href={`mailto:${contactEmail}`}
                  className="font-medium text-foreground underline underline-offset-4"
                >
                  {contactEmail}
                </a>
                .
              </p>
              <p>Paquete Android oficial: com.karrito.app.</p>
            </section>
          </CardContent>
        </Card>
      </main>
    </div>
  );
}
