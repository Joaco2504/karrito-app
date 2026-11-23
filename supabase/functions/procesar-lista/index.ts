import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "@supabase/supabase-js";
import { corsHeaders } from "@supabase/supabase-js/cors";
import { GoogleGenAI } from "@google/genai";

const GEMINI_MODEL = "gemini-4-hydrogen";
const MAX_TEXT_LENGTH = 8_000;
const MAX_MEDIA_BASE64_LENGTH = 14_000_000;
const DEFAULT_FREE_DAILY_AI_LIMIT = 5;

const STORE_AISLES = {
  "Supermercado": [
    "Verdulería y Frutería",
    "Carnicería y Pescadería",
    "Fiambrería y Quesos",
    "Lácteos y Refrigerados",
    "Panadería",
    "Almacén",
    "Bebidas",
    "Limpieza",
    "Perfumería e Higiene",
    "Congelados",
    "Mascotas",
  ],
  "Ferretería / Corralón": [
    "Fijaciones",
    "Electricidad e Iluminación",
    "Plomería y Gas",
    "Pinturería",
    "Herramientas",
    "Adhesivos y Selladores",
  ],
  "Farmacia": [
    "Medicamentos",
    "Primeros Auxilios",
    "Cuidado Personal y Dermocosmética",
    "Bebés y Maternidad",
  ],
  "Librería / Papelería": [
    "Útiles Escolares",
    "Oficina",
    "Artística",
  ],
  "Dietética / Naturista": [
    "Frutos Secos y Semillas",
    "Harinas y Cereales",
    "Suplementos",
    "Sin TACC",
  ],
  "Bazar y Hogar": [
    "Cocina y Vajilla",
    "Herméticos y Organización",
    "Termos y Mate",
    "Decoración y Textil Hogar",
  ],
  "Indumentaria y Calzado": [
    "Ropa Cotidiana",
    "Ropa Interior y Medias",
    "Calzado",
    "Accesorios",
  ],
  "Juguetería y Regalería": [
    "Juguetes",
    "Juegos de Mesa",
    "Cotillón y Envoltorios",
  ],
  "Mascotas y Veterinaria": [
    "Alimento Balanceado",
    "Higiene y Piedritas",
    "Salud y Pipetas",
    "Accesorios Mascotas",
  ],
  "Electrónica y Celulares": [
    "Cargadores y Cables",
    "Pilas y Baterías",
    "Audio y Accesorios",
    "Informática Básica",
  ],
  "Otros / Varios": [
    "Varios",
    "Automotor",
    "Vivero",
  ],
} as const;

type StoreCategory = keyof typeof STORE_AISLES;
const STORE_CATEGORIES = Object.keys(STORE_AISLES) as StoreCategory[];

interface ParsedShoppingItem {
  clean_name: string;
  quantity: number;
  unit: string;
  store_category: StoreCategory;
  aisle_name: string;
  recipe_note?: string;
}

interface UserProfileRow {
  id: string;
  plan_tier: "free" | "basic_2usd" | "pro_3usd";
  daily_ai_count: number;
  last_ai_date: string;
  is_banned: boolean;
}

interface ProcessRequestPayload {
  text?: unknown;
  audio_base64?: unknown;
  audio_mime_type?: unknown;
  image_base64?: unknown;
  image_mime_type?: unknown;
  is_recipe?: unknown;
}

const ITEM_BASE_PROPERTIES = {
  clean_name: {
    type: "string",
    description:
      "Nombre limpio del producto en español argentino con mayúscula inicial, sin la cantidad ni el comercio.",
  },
  quantity: {
    type: "number",
    description:
      "Cantidad numérica positiva a comprar en el comercio (en modo receta, normalizada a un empaque comercial real argentino). Si no se indica cantidad, usar 1.",
  },
  unit: {
    type: "string",
    description:
      "Unidad corta en español: unidad, kg, g, litro, ml, paquete, caja, blíster, docena, metro, lata, botella.",
  },
  recipe_note: {
    type: "string",
    description:
      "Solo cuando is_recipe=true: cantidad exacta original que pide la receta (ej: '100 g para el flan', '150 ml para la masa'). En listas comunes dejar vacío.",
  },
};

function buildStoreBranchSchema(
  store: StoreCategory,
  aisles: readonly string[],
  allowDynamicAisle: boolean,
) {
  return {
    type: "object",
    properties: {
      ...ITEM_BASE_PROPERTIES,
      store_category: {
        type: "string",
        enum: [store],
      },
      aisle_name: allowDynamicAisle
        ? {
          type: "string",
          description:
            "Usá Varios, Automotor, Vivero o una categoría corta en español (máximo 3 palabras) si el producto no encaja en ninguno de los otros rubros.",
        }
        : {
          type: "string",
          enum: [...aisles],
        },
    },
    required: ["clean_name", "quantity", "unit", "store_category", "aisle_name"],
  };
}

const LIST_RESPONSE_SCHEMA = {
  type: "object",
  properties: {
    items: {
      type: "array",
      description:
        "Lista ordenada de productos extraídos del texto, audio o imagen. Devolver arreglo vacío si no hay productos.",
      items: {
        anyOf: STORE_CATEGORIES.map((store) =>
          buildStoreBranchSchema(
            store,
            STORE_AISLES[store],
            store === "Otros / Varios",
          )
        ),
      },
    },
  },
  required: ["items"],
};

const SYSTEM_INSTRUCTION = `Sos un clasificador de listas de compras para Argentina (en especial el noroeste argentino y Catamarca).
Tu tarea es extraer cada producto de un texto libre, audio dictado o foto de lista escrita a mano, normalizar su nombre y asignarle exactamente un comercio (store_category) y un pasillo (aisle_name).

Reglas de normalización:
1. Separá líneas o frases que incluyan varios productos en ítems individuales. Ignorá saludos, comentarios o texto que no corresponda a compras.
2. En clean_name escribí el producto claro en español argentino con mayúscula inicial (ej: "1/2 de nalga para milanesa" -> clean_name: "Milanesas de nalga", quantity: 0.5, unit: "kg"; "2 cocas 2.25" -> clean_name: "Coca-Cola 2,25 L", quantity: 2, unit: "botella"). Conservá la marca o detalle útil si el usuario la mencionó.
3. En quantity devolvé siempre un número mayor a 0 (ej: "medio kilo" -> 0.5, "una docena" -> 12 con unit "unidad" o 1 con unit "docena", sin cantidad -> 1).
4. En unit usá unidades cortas y claras en español: "unidad", "kg", "g", "litro", "ml", "paquete", "caja", "blíster", "docena", "metro", "lata", "botella".

Comercios y pasillos exactos permitidos:
1. "Supermercado": "Verdulería y Frutería", "Carnicería y Pescadería", "Fiambrería y Quesos", "Lácteos y Refrigerados", "Panadería", "Almacén", "Bebidas", "Limpieza", "Perfumería e Higiene", "Congelados", "Mascotas".
   - Quesos fraccionados, jamón, salame -> "Fiambrería y Quesos". Leche, yogur, manteca, crema -> "Lácteos y Refrigerados".
   - Yerba, fideos, arroz, aceite, azúcar, galletitas -> "Almacén". Lavandina, detergente, esponja -> "Limpieza". Jabón de tocador, shampoo, papel higiénico, pasta dental -> "Perfumería e Higiene".
2. "Ferretería / Corralón": "Fijaciones", "Electricidad e Iluminación", "Plomería y Gas", "Pinturería", "Herramientas", "Adhesivos y Selladores".
   - Tornillos, clavos, tarugos, bulones, arandelas -> "Fijaciones". Cables, focos, cinta aisladora, enchufes -> "Electricidad e Iluminación". Caños, teflón, cueritos -> "Plomería y Gas". La gotita, silicona, poxipol -> "Adhesivos y Selladores".
3. "Farmacia": "Medicamentos", "Primeros Auxilios", "Cuidado Personal y Dermocosmética", "Bebés y Maternidad".
   - Tafirol, ibuprofeno, amoxicilina, jarabe, pastillas -> "Medicamentos". Alcohol, gasas, curitas, agua oxigenada -> "Primeros Auxilios". Pañales, mamadera, óleo calcáreo -> "Bebés y Maternidad".
4. "Librería / Papelería": "Útiles Escolares", "Oficina", "Artística".
5. "Dietética / Naturista": "Frutos Secos y Semillas", "Harinas y Cereales", "Suplementos", "Sin TACC".
6. "Bazar y Hogar": "Cocina y Vajilla", "Herméticos y Organización", "Termos y Mate", "Decoración y Textil Hogar".
   - Ollas, sartenes, platos, vasos, cubiertos -> "Cocina y Vajilla". Tuppers, frascos, organizadores -> "Herméticos y Organización". Termo, mate, bombilla -> "Termos y Mate". Sábanas, toallas, cortinas, repasadores -> "Decoración y Textil Hogar".
7. "Indumentaria y Calzado": "Ropa Cotidiana", "Ropa Interior y Medias", "Calzado", "Accesorios".
   - Remeras, pantalones, buzos, camperas -> "Ropa Cotidiana". Medias, bombachas, boxers -> "Ropa Interior y Medias". Zapatillas, ojotas, botas -> "Calzado". Gorras, cinturones, bufandas -> "Accesorios".
8. "Juguetería y Regalería": "Juguetes", "Juegos de Mesa", "Cotillón y Envoltorios".
   - Pelotas, muñecos, autitos -> "Juguetes". Cartas, rompecabezas, ajedrez -> "Juegos de Mesa". Globos, velitas, papel de regalo, bolsas -> "Cotillón y Envoltorios".
9. "Mascotas y Veterinaria": "Alimento Balanceado", "Higiene y Piedritas", "Salud y Pipetas", "Accesorios Mascotas".
   - Comida para perro o gato por bolsa grande o específica de veterinaria/pet shop -> "Alimento Balanceado". Piedras sanitarias, shampoo para perro -> "Higiene y Piedritas". Pipeta, antiparasitario -> "Salud y Pipetas". Collar, correa, comedero -> "Accesorios Mascotas". (Si el usuario claramente pide algo chico de góndola junto a compras del súper, puede ir en "Supermercado" -> "Mascotas", pero ante pedido específico de mascotas o veterinaria preferí "Mascotas y Veterinaria").
10. "Electrónica y Celulares": "Cargadores y Cables", "Pilas y Baterías", "Audio y Accesorios", "Informática Básica".
   - Cargador USB-C, cable de celular, adaptador -> "Cargadores y Cables". Pilas AA/AAA, baterías -> "Pilas y Baterías". Auriculares, parlante, funda o vidrio templado -> "Audio y Accesorios". Mouse, pendrive, teclado -> "Informática Básica".
11. "Otros / Varios": "Varios", "Automotor", "Vivero", o una categoría corta de máximo 3 palabras si el producto no entra en ninguno de los 10 rubros anteriores.`;

const RECIPE_SYSTEM_ADDENDUM = `

MODO RECETA ACTIVO (is_recipe = true):
El usuario ingresó el nombre de una comida, una receta escrita o una foto/captura de una receta.
1. Si el usuario solo nombró un plato y cantidad de personas (ej: "Flan casero para 6 personas" o "Empanadas catamarqueñas para 4"), generá la lista completa de ingredientes típicos en Argentina. Si adjuntó texto o foto de una receta, extraé todos sus ingredientes.
2. NORMALIZACIÓN OBLIGATORIA A EMPAQUES COMERCIALES REALES DE ARGENTINA: nunca devuelvas micro-cantidades imposibles de comprar sueltas en un supermercado argentino. Convertí cada ingrediente al empaque comercial mínimo estándar:
   - Azúcar, harina, arroz, polenta: 100 g / 250 g / 500 g -> quantity: 1, unit: "kg".
   - Aceite o vinagre: 50 ml / 150 ml / 200 ml -> quantity: 1, unit: "litro" (o 900 ml).
   - Leche líquida: 250 ml / 500 ml -> quantity: 1, unit: "litro".
   - Huevos: 1 a 5 huevos -> quantity: 6, unit: "unidad" (media docena); 7 a 12 -> quantity: 12, unit: "unidad" (o 1 docena).
   - Manteca / margarina: hasta 100 g -> quantity: 100, unit: "g"; entre 101 g y 200 g -> quantity: 200, unit: "g".
   - Crema de leche: hasta 200 ml -> quantity: 200, unit: "ml".
   - Sal fina/gruesa: hasta 500 g -> quantity: 500, unit: "g".
   - Especias, esencia de vainilla, polvo de hornear, levadura: "1 cdita", "una pizca" -> quantity: 1, unit: "paquete" o "botella" o "unidad".
   - Verduras, frutas y carnes que sí se venden al peso: mantené el peso real (ej: 0.5 kg cebolla, 1 kg carne picada).
3. En recipe_note escribí SIEMPRE la cantidad exacta que pide la receta original en forma breve y clara en español argentino (ej: "100 g para el flan", "150 ml para la mezcla", "4 u para el flan", "1 cdita para el caramelo").`;

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json; charset=utf-8",
    },
  });
}

function getArgentinaDateISO(now = new Date()): string {
  // Argentina keeps UTC-3 year-round without daylight saving time.
  const argMillis = now.getTime() - 3 * 60 * 60 * 1000;
  return new Date(argMillis).toISOString().slice(0, 10);
}

function parsePositiveInt(raw: string | null | undefined, fallback: number): number {
  if (!raw) return fallback;
  const parsed = Number.parseInt(raw.trim(), 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function cleanBase64(value: unknown): string {
  if (typeof value !== "string") return "";
  const trimmed = value.trim();
  if (!trimmed) return "";
  return trimmed.replace(/^data:[^;]+;base64,/i, "").replace(/\s+/g, "");
}

function normalizeAudioMimeType(raw: unknown): string | null {
  if (raw === undefined || raw === null || raw === "") return "audio/m4a";
  if (typeof raw !== "string") return null;
  const normalized = raw.trim().toLowerCase();
  if (normalized === "audio/m4a" || normalized === "audio/mp4" || normalized === "audio/x-m4a") {
    return "audio/m4a";
  }
  if (normalized === "audio/aac") {
    return "audio/aac";
  }
  return null;
}

function normalizeImageMimeType(raw: unknown): string | null {
  if (raw === undefined || raw === null || raw === "") return "image/jpeg";
  if (typeof raw !== "string") return null;
  const normalized = raw.trim().toLowerCase();
  if (normalized === "image/jpeg" || normalized === "image/jpg") {
    return "image/jpeg";
  }
  return null;
}

function normalizeTextKey(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
}

const STORE_LOOKUP = new Map<string, StoreCategory>(
  STORE_CATEGORIES.map((s) => [normalizeTextKey(s), s]),
);

const AISLE_LOOKUP_BY_STORE = new Map<StoreCategory, Map<string, string>>(
  STORE_CATEGORIES.map((store) => [
    store,
    new Map(STORE_AISLES[store].map((aisle) => [normalizeTextKey(aisle), aisle])),
  ]),
);

function sanitizeItems(rawItems: unknown): ParsedShoppingItem[] {
  if (!Array.isArray(rawItems)) return [];

  const sanitized: ParsedShoppingItem[] = [];

  for (const entry of rawItems) {
    if (!entry || typeof entry !== "object") continue;
    const obj = entry as Record<string, unknown>;

    const rawName = typeof obj.clean_name === "string" ? obj.clean_name.trim() : "";
    if (!rawName) continue;

    const rawQty = typeof obj.quantity === "number"
      ? obj.quantity
      : Number(obj.quantity);
    const quantity = Number.isFinite(rawQty) && rawQty > 0 ? rawQty : 1;

    const rawUnit = typeof obj.unit === "string" ? obj.unit.trim() : "";
    const unit = rawUnit || "unidad";

    const rawStore = typeof obj.store_category === "string" ? obj.store_category : "";
    const matchedStore = STORE_LOOKUP.get(normalizeTextKey(rawStore)) ?? "Otros / Varios";

    const rawAisle = typeof obj.aisle_name === "string" ? obj.aisle_name.trim() : "";
    const storeAisles = AISLE_LOOKUP_BY_STORE.get(matchedStore)!;
    const matchedAisle = storeAisles.get(normalizeTextKey(rawAisle));

    let aisleName: string;
    if (matchedAisle) {
      aisleName = matchedAisle;
    } else if (matchedStore === "Otros / Varios" && rawAisle) {
      aisleName = rawAisle.slice(0, 40);
    } else {
      aisleName = matchedStore === "Supermercado"
        ? "Almacén"
        : STORE_AISLES[matchedStore][0];
    }

    const rawNote = typeof obj.recipe_note === "string"
      ? obj.recipe_note.trim().slice(0, 120)
      : "";

    sanitized.push({
      clean_name: rawName,
      quantity,
      unit,
      store_category: matchedStore,
      aisle_name: aisleName,
      ...(rawNote ? { recipe_note: rawNote } : {}),
    });
  }

  return sanitized;
}

function extractInteractionText(interaction: unknown): string {
  if (!interaction || typeof interaction !== "object") return "";
  const record = interaction as Record<string, unknown>;

  if (typeof record.output_text === "string" && record.output_text.trim()) {
    return record.output_text.trim();
  }

  if (Array.isArray(record.steps)) {
    const chunks: string[] = [];
    for (const step of record.steps) {
      if (!step || typeof step !== "object") continue;
      const stepObj = step as Record<string, unknown>;
      if (stepObj.type !== "model_output" || !Array.isArray(stepObj.content)) continue;
      for (const part of stepObj.content) {
        if (!part || typeof part !== "object") continue;
        const partObj = part as Record<string, unknown>;
        if (partObj.type === "text" && typeof partObj.text === "string") {
          chunks.push(partObj.text);
        }
      }
    }
    return chunks.join("").trim();
  }

  return "";
}

function buildGeminiInput(
  text: string,
  audioBase64: string,
  audioMimeType: string,
  imageBase64: string,
  imageMimeType: string,
  isRecipe: boolean,
) {
  const parts: Array<Record<string, unknown>> = [];

  if (isRecipe) {
    parts.push({
      type: "text",
      text: text
        ? `Analizá la siguiente receta o comida, extraé sus ingredientes normalizados a empaques reales de comercios argentinos, anotá la cantidad exacta original en recipe_note y clasificalos por comercio y pasillo:\n\n${text}`
        : "Leé la receta de la imagen adjunta, extraé todos sus ingredientes normalizados a empaques reales de comercios argentinos, anotá la cantidad exacta original en recipe_note y clasificalos por comercio y pasillo.",
    });
  } else if (text) {
    parts.push({
      type: "text",
      text: `Extraé y clasificá todos los productos de compra del siguiente pedido:\n\n${text}`,
    });
  } else {
    parts.push({
      type: "text",
      text: "Transcribí o leé el contenido adjunto, extraé cada producto de compra y clasificalo por comercio y pasillo.",
    });
  }

  if (audioBase64) {
    parts.push({
      type: "audio",
      data: audioBase64,
      mime_type: audioMimeType,
    });
  }

  if (imageBase64) {
    parts.push({
      type: "image",
      data: imageBase64,
      mime_type: imageMimeType,
    });
  }

  return parts;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse(
      { error: "Método no permitido. Usá POST para procesar una lista." },
      405,
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseAnonKey =
    Deno.env.get("SUPABASE_ANON_KEY") ??
    Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
    "";
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const geminiApiKey = Deno.env.get("GEMINI_API_KEY") ?? "";

  if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey || !geminiApiKey) {
    console.error("Missing required server environment variables.");
    return jsonResponse(
      { error: "Falta configurar el servidor para ordenar listas. Avisanos si el problema sigue." },
      500,
    );
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.toLowerCase().startsWith("bearer ")) {
    return jsonResponse(
      { error: "No pudimos validar tu sesión. Cerrá y volvé a entrar a la aplicación para continuar." },
      401,
    );
  }
  const jwt = authHeader.slice(7).trim();
  if (!jwt) {
    return jsonResponse(
      { error: "No pudimos validar tu sesión. Cerrá y volvé a entrar a la aplicación para continuar." },
      401,
    );
  }

  const userClient = createClient(supabaseUrl, supabaseAnonKey, {
    db: { schema: "karrito" },
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey, {
    db: { schema: "karrito" },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const {
    data: { user },
    error: authError,
  } = await userClient.auth.getUser(jwt);

  if (authError || !user) {
    return jsonResponse(
      { error: "Tu sesión venció o no es válida. Volvé a iniciar sesión para ordenar tu lista." },
      401,
    );
  }

  let { data: profile, error: profileError } = await userClient
    .from("users_profile")
    .select("id, plan_tier, daily_ai_count, last_ai_date, is_banned")
    .eq("id", user.id)
    .maybeSingle<UserProfileRow>();

  if (profileError) {
    console.error("Error reading karrito.users_profile:", profileError);
    return jsonResponse(
      { error: "No pudimos consultar tu cuenta en este momento. Probá de nuevo en unos segundos." },
      500,
    );
  }

  if (!profile) {
    // Handles pre-existing auth.users accounts that existed before the Karrito signup trigger.
    const { data: createdProfile, error: upsertError } = await adminClient
      .from("users_profile")
      .upsert(
        { id: user.id, email: user.email ?? null },
        { onConflict: "id" },
      )
      .select("id, plan_tier, daily_ai_count, last_ai_date, is_banned")
      .single<UserProfileRow>();

    if (upsertError || !createdProfile) {
      console.error("Error creating missing karrito.users_profile:", upsertError);
      return jsonResponse(
        { error: "No pudimos preparar tu perfil en este momento. Probá de nuevo en unos segundos." },
        500,
      );
    }
    profile = createdProfile;
  }

  if (profile.is_banned) {
    return jsonResponse(
      {
        error:
          "Tu cuenta tiene el acceso bloqueado para ordenar listas con IA. Comunicate con soporte para revisar tu caso.",
        code: "USER_BANNED",
      },
      403,
    );
  }

  let payload: ProcessRequestPayload;
  try {
    payload = (await req.json()) as ProcessRequestPayload;
  } catch {
    return jsonResponse(
      { error: "El pedido no tiene un formato válido. Actualizá la aplicación o probá de nuevo." },
      400,
    );
  }

  const text = typeof payload.text === "string" ? payload.text.trim() : "";
  const audioBase64 = cleanBase64(payload.audio_base64);
  const imageBase64 = cleanBase64(payload.image_base64);
  const isRecipe = payload.is_recipe === true;

  if (!text && !audioBase64 && !imageBase64) {
    return jsonResponse(
      { error: "Escribí al menos un producto, grabá un audio o sacá una foto para armar la lista." },
      400,
    );
  }

  if (text.length > MAX_TEXT_LENGTH) {
    return jsonResponse(
      { error: "El texto es demasiado largo para procesarlo junto. Dividilo en listas más cortas e intentá de nuevo." },
      400,
    );
  }

  if (
    audioBase64.length > MAX_MEDIA_BASE64_LENGTH ||
    imageBase64.length > MAX_MEDIA_BASE64_LENGTH
  ) {
    return jsonResponse(
      { error: "El archivo pesa demasiado para analizarlo. Sacá una foto más liviana o grabá un audio más corto." },
      413,
    );
  }

  const audioMimeType = normalizeAudioMimeType(payload.audio_mime_type);
  const imageMimeType = normalizeImageMimeType(payload.image_mime_type);

  if ((audioBase64 && !audioMimeType) || (imageBase64 && !imageMimeType)) {
    return jsonResponse(
      { error: "Ese formato de archivo no es compatible. Usá audio M4A o foto en JPEG." },
      400,
    );
  }

  if ((audioBase64 || imageBase64) && profile.plan_tier !== "pro_3usd") {
    return jsonResponse(
      {
        error:
          "El dictado por voz y el escaneo de fotos están disponibles solo en el plan Pro. Con tu plan actual podés escribir o pegar tu lista en texto.",
        code: "PRO_PLAN_REQUIRED",
      },
      403,
    );
  }

  const { data: configRow, error: configError } = await userClient
    .from("app_config")
    .select("value")
    .eq("key", "free_daily_ai_limit")
    .maybeSingle<{ value: string }>();

  if (configError) {
    console.error("Error reading karrito.app_config:", configError);
  }

  const freeDailyLimit = parsePositiveInt(
    configRow?.value,
    DEFAULT_FREE_DAILY_AI_LIMIT,
  );
  const todayArg = getArgentinaDateISO();
  const usedToday = profile.last_ai_date === todayArg ? profile.daily_ai_count : 0;

  if (profile.plan_tier === "free" && usedToday >= freeDailyLimit) {
    return jsonResponse(
      {
        error:
          `Ya usaste tus ${freeDailyLimit} cargas gratuitas con IA de hoy. Podés agregar productos a mano, volver mañana o elegir un plan pago.`,
        code: "DAILY_LIMIT_REACHED",
        limit: freeDailyLimit,
        used: usedToday,
      },
      429,
    );
  }

  let items: ParsedShoppingItem[];
  try {
    const ai = new GoogleGenAI({
      apiKey: geminiApiKey,
      apiVersion: "v1beta",
    });
    const interaction = await ai.interactions.create({
      model: GEMINI_MODEL,
      system_instruction: isRecipe
        ? `${SYSTEM_INSTRUCTION}${RECIPE_SYSTEM_ADDENDUM}`
        : SYSTEM_INSTRUCTION,
      input: buildGeminiInput(
        text,
        audioBase64,
        audioMimeType ?? "audio/m4a",
        imageBase64,
        imageMimeType ?? "image/jpeg",
        isRecipe,
      ) as never,
      generation_config: {
        thinking_level: "low",
      },
      response_format: {
        type: "text",
        mime_type: "application/json",
        schema: LIST_RESPONSE_SCHEMA,
      },
      store: false,
    });

    const rawText = extractInteractionText(interaction);
    if (!rawText) {
      throw new Error("Empty response from Gemini Interactions API.");
    }

    const parsed = JSON.parse(rawText) as { items?: unknown };
    items = sanitizeItems(parsed?.items);
  } catch (err) {
    console.error("Gemini processing error:", err);
    return jsonResponse(
      {
        error:
          "No pudimos ordenar tu lista en este momento porque el servicio de análisis falló. Probá de nuevo en unos segundos.",
      },
      502,
    );
  }

  // Must use service_role because trg_protect_user_fields strips updates from regular users.
  const nextCount = usedToday + 1;
  const { error: counterError } = await adminClient
    .from("users_profile")
    .update({
      daily_ai_count: nextCount,
      last_ai_date: todayArg,
    })
    .eq("id", user.id);

  if (counterError) {
    console.error("Error incrementing daily_ai_count:", counterError);
  }

  return jsonResponse({
    items,
    quota: {
      plan_tier: profile.plan_tier,
      daily_ai_count: nextCount,
      daily_ai_limit: profile.plan_tier === "free" ? freeDailyLimit : null,
      remaining:
        profile.plan_tier === "free"
          ? Math.max(0, freeDailyLimit - nextCount)
          : null,
    },
  });
});
