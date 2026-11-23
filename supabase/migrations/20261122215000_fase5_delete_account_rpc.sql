-- Fase 5: Función RPC obligatoria para Google Play que elimina completamente
-- la cuenta del usuario autenticado (datos en karrito.* y registro en auth.users).

CREATE OR REPLACE FUNCTION karrito.delete_my_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = karrito, auth, public
AS $$
DECLARE
  v_uid uuid := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'No pudimos validar tu sesión para eliminar la cuenta.';
  END IF;

  -- Eliminar membresías en listas ajenas y luego las listas propias (cascada sobre list_items y list_members).
  DELETE FROM karrito.list_members WHERE user_id = v_uid;
  DELETE FROM karrito.shopping_lists WHERE owner_id = v_uid;
  DELETE FROM karrito.aisle_preferences WHERE user_id = v_uid;
  DELETE FROM karrito.learned_items WHERE user_id = v_uid;
  DELETE FROM karrito.users_profile WHERE id = v_uid;

  -- Eliminar el registro de autenticación en Supabase Auth.
  DELETE FROM auth.users WHERE id = v_uid;
END;
$$;

REVOKE ALL ON FUNCTION karrito.delete_my_account() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION karrito.delete_my_account() TO authenticated, service_role;
