-- Fase 5.4: Hardening de seguridad para Storage (`ads-media`), RLS y proteccion
-- de propiedad de listas colaborativas antes de publicacion en Google Play.

-- 1. Restricciones estrictas en el bucket publico `ads-media`:
--    - Maximo 2 MB (2097152 bytes) por imagen
--    - Solo formatos de imagen seguros: PNG, JPEG y WebP (bloquea SVG/HTML/scripts)
UPDATE storage.buckets
SET
  file_size_limit = 2097152,
  allowed_mime_types = ARRAY['image/png', 'image/jpeg', 'image/webp']
WHERE id = 'ads-media';

-- 2. Reafirmar RLS habilitado en las 9 tablas del schema `karrito` (idempotente)
ALTER TABLE karrito.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.aisle_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.app_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.learned_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.list_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.list_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.local_ads ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.shopping_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.users_profile ENABLE ROW LEVEL SECURITY;

-- 3. Proteger campos sensibles de `karrito.shopping_lists` (`owner_id`, `is_shared`,
--    `share_code`) para que un miembro invitado pueda sincronizar el titulo sin
--    poder apropiarse de la lista ni alterar el codigo compartido.
CREATE OR REPLACE FUNCTION karrito.protect_shopping_list_ownership()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = karrito, public
AS $$
BEGIN
  IF auth.role() = 'service_role'
     OR session_user IN ('postgres', 'supabase_admin')
     OR karrito.is_admin() THEN
    RETURN NEW;
  END IF;

  -- Nadie puede transferir ownership de una lista existente desde el cliente.
  IF NEW.owner_id IS DISTINCT FROM OLD.owner_id THEN
    RAISE EXCEPTION 'No tenés permiso para cambiar el propietario de esta lista.'
      USING ERRCODE = '42501';
  END IF;

  -- Solo el propietario puede activar/desactivar el modo compartido o cambiar share_code.
  IF OLD.owner_id IS DISTINCT FROM auth.uid() THEN
    IF NEW.is_shared IS DISTINCT FROM OLD.is_shared
       OR NEW.share_code IS DISTINCT FROM OLD.share_code THEN
      RAISE EXCEPTION 'Solo el dueño de la lista puede cambiar el estado compartido.'
        USING ERRCODE = '42501';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_protect_shopping_list_ownership ON karrito.shopping_lists;
CREATE TRIGGER trg_protect_shopping_list_ownership
  BEFORE UPDATE ON karrito.shopping_lists
  FOR EACH ROW
  EXECUTE FUNCTION karrito.protect_shopping_list_ownership();
