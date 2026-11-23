import { NextResponse, type NextRequest } from "next/server";
import { requireAdminSession } from "@/lib/auth/admin";
import { ADS_STORAGE_BUCKET } from "@/lib/constants/karrito";
import { createAdminSupabaseClient } from "@/lib/supabase/admin";

const ALLOWED_MIME_TYPES = new Set(["image/jpeg", "image/png", "image/webp"]);

// Must match `storage.buckets.file_size_limit = 2097152` on `ads-media`.
const MAX_FILE_BYTES = 2 * 1024 * 1024; // 2 MB

function detectMagicImageMime(bytes: Uint8Array): string | null {
  if (bytes.length < 12) return null;

  // PNG: 89 50 4E 47 0D 0A 1A 0A
  if (
    bytes[0] === 0x89 &&
    bytes[1] === 0x50 &&
    bytes[2] === 0x4e &&
    bytes[3] === 0x47 &&
    bytes[4] === 0x0d &&
    bytes[5] === 0x0a &&
    bytes[6] === 0x1a &&
    bytes[7] === 0x0a
  ) {
    return "image/png";
  }

  // JPEG: FF D8 FF
  if (bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff) {
    return "image/jpeg";
  }

  // WebP: RIFF....WEBP
  if (
    bytes[0] === 0x52 &&
    bytes[1] === 0x49 &&
    bytes[2] === 0x46 &&
    bytes[3] === 0x46 &&
    bytes[8] === 0x57 &&
    bytes[9] === 0x45 &&
    bytes[10] === 0x42 &&
    bytes[11] === 0x50
  ) {
    return "image/webp";
  }

  return null;
}

function getFileExtension(mimeType: string): string {
  switch (mimeType) {
    case "image/png":
      return "png";
    case "image/webp":
      return "webp";
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
        error: "Formato no compatible. Subí una imagen JPG, PNG o WebP.",
      },
      { status: 400 },
    );
  }

  if (file.size === 0 || file.size > MAX_FILE_BYTES) {
    return NextResponse.json(
      {
        error:
          "La imagen pesa más de 2 MB o está vacía. Comprimila y probá de nuevo.",
      },
      { status: 400 },
    );
  }

  const arrayBuffer = await file.arrayBuffer();
  const bytes = new Uint8Array(arrayBuffer);
  const detectedMime = detectMagicImageMime(bytes);
  if (!detectedMime || !ALLOWED_MIME_TYPES.has(detectedMime)) {
    return NextResponse.json(
      {
        error:
          "El contenido del archivo no corresponde a una imagen válida PNG, JPG o WebP.",
      },
      { status: 400 },
    );
  }

  const ext = getFileExtension(detectedMime);
  const randomSuffix = crypto.randomUUID().slice(0, 8);
  const storagePath = `local-ads/${slot}/${Date.now()}-${randomSuffix}-${slug}.${ext}`;

  const adminClient = createAdminSupabaseClient();

  const { error: uploadError } = await adminClient.storage
    .from(ADS_STORAGE_BUCKET)
    .upload(storagePath, Buffer.from(arrayBuffer), {
      contentType: detectedMime,
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
