import { NextResponse, type NextRequest } from "next/server";
import { requireAdminSession } from "@/lib/auth/admin";
import { ADS_STORAGE_BUCKET } from "@/lib/constants/karrito";
import { createAdminSupabaseClient } from "@/lib/supabase/admin";

const ALLOWED_MIME_TYPES = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/gif",
]);

const MAX_FILE_BYTES = 5 * 1024 * 1024; // 5 MB

function getFileExtension(mimeType: string): string {
  switch (mimeType) {
    case "image/png":
      return "png";
    case "image/webp":
      return "webp";
    case "image/gif":
      return "gif";
    default:
      return "jpg";
  }
}

function slugifyName(raw: string): string {
  return (
    raw
      .trim()
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
      .slice(0, 40) || "comercio"
  );
}

export async function POST(request: NextRequest) {
  const session = await requireAdminSession();
  if (!session.authorized) {
    const status = session.reason === "unauthenticated" ? 401 : 403;
    return NextResponse.json(
      {
        error:
          "No tenés permisos para subir imágenes. Iniciá sesión con la cuenta administradora.",
      },
      { status },
    );
  }

  let formData: FormData;
  try {
    formData = await request.formData();
  } catch {
    return NextResponse.json(
      { error: "No pudimos leer el archivo enviado. Volvé a seleccionarlo." },
      { status: 400 },
    );
  }

  const file = formData.get("file");
  const slotRaw = formData.get("slot");
  const businessNameRaw = formData.get("businessName");

  if (!(file instanceof File)) {
    return NextResponse.json(
      { error: "Elegí una imagen antes de subirla." },
      { status: 400 },
    );
  }

  const slot = slotRaw === "interstitial" ? "interstitial" : "banner";
  const slug =
    typeof businessNameRaw === "string"
      ? slugifyName(businessNameRaw)
      : "comercio";

  if (!ALLOWED_MIME_TYPES.has(file.type)) {
    return NextResponse.json(
      {
        error:
          "Formato no compatible. Subí una imagen JPG, PNG, WebP o GIF.",
      },
      { status: 400 },
    );
  }

  if (file.size === 0 || file.size > MAX_FILE_BYTES) {
    return NextResponse.json(
      {
        error:
          "La imagen pesa más de 5 MB o está vacía. Comprimila y probá de nuevo.",
      },
      { status: 400 },
    );
  }

  const ext = getFileExtension(file.type);
  const randomSuffix = Math.random().toString(36).slice(2, 8);
  const storagePath = `local-ads/${slot}/${Date.now()}-${randomSuffix}-${slug}.${ext}`;

  const arrayBuffer = await file.arrayBuffer();
  const adminClient = createAdminSupabaseClient();

  const { error: uploadError } = await adminClient.storage
    .from(ADS_STORAGE_BUCKET)
    .upload(storagePath, Buffer.from(arrayBuffer), {
      contentType: file.type,
      cacheControl: "3600",
      upsert: false,
    });

  if (uploadError) {
    return NextResponse.json(
      {
        error: `No pudimos subir la imagen al bucket ${ADS_STORAGE_BUCKET}: ${uploadError.message}`,
      },
      { status: 500 },
    );
  }

  const {
    data: { publicUrl },
  } = adminClient.storage.from(ADS_STORAGE_BUCKET).getPublicUrl(storagePath);

  return NextResponse.json({
    ok: true,
    url: publicUrl,
    path: storagePath,
  });
}
