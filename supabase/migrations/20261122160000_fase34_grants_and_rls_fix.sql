-- Fase 3.4: Garantizar permisos GRANT del schema karrito y corregir políticas RLS
-- (elimina de raíz el error 42501 en UPSERT de shopping_lists y tablas de sincronización).
--
-- Causa raíz diagnosticada en producción:
--   `shopping_lists_update` tenía `USING (is_list_member(id) AND is_not_banned())` sin
--   `WITH CHECK` explícito. En PostgreSQL, `INSERT ... ON CONFLICT (id) DO UPDATE` evalúa
--   el `WITH CHECK` de la política `UPDATE` incluso cuando inserta una fila nueva. Como la
--   fila nueva todavía no existe en `karrito.shopping_lists` dentro de la función
--   `SECURITY DEFINER` `is_list_member(id)`, devolvía `false` y lanzaba SQLSTATE 42501
--   en todos los UPSERT de listas nuevas de usuarios no administradores.

-- 1. Permisos GRANT del schema, tablas, secuencias y funciones
GRANT USAGE ON SCHEMA karrito TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA karrito TO authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA karrito TO authenticated, service_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA karrito TO anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA karrito
  GRANT ALL ON TABLES TO authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA karrito
  GRANT ALL ON SEQUENCES TO authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA karrito
  GRANT EXECUTE ON FUNCTIONS TO anon, authenticated, service_role;

-- 2. Garantizar RLS habilitado en las 6 tablas de sincronización del usuario
ALTER TABLE karrito.users_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.shopping_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.list_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.list_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.aisle_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE karrito.learned_items ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------------
-- 3. users_profile (SELECT, INSERT, UPDATE, DELETE explícitos)
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS users_profile_select ON karrito.users_profile;
DROP POLICY IF EXISTS users_profile_insert ON karrito.users_profile;
DROP POLICY IF EXISTS users_profile_update ON karrito.users_profile;
DROP POLICY IF EXISTS users_profile_delete ON karrito.users_profile;

CREATE POLICY users_profile_select ON karrito.users_profile
  FOR SELECT TO authenticated
  USING (id = auth.uid() OR karrito.is_admin());

CREATE POLICY users_profile_insert ON karrito.users_profile
  FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid() OR karrito.is_admin());

CREATE POLICY users_profile_update ON karrito.users_profile
  FOR UPDATE TO authenticated
  USING (id = auth.uid() OR karrito.is_admin())
  WITH CHECK (id = auth.uid() OR karrito.is_admin());

CREATE POLICY users_profile_delete ON karrito.users_profile
  FOR DELETE TO authenticated
  USING (id = auth.uid() OR karrito.is_admin());

-- ---------------------------------------------------------------------------
-- 4. shopping_lists (SELECT, INSERT, UPDATE, DELETE explícitos)
--    Evalúa `owner_id = auth.uid()` directo sobre la fila nueva en WITH CHECK
--    para que INSERT ... ON CONFLICT DO UPDATE funcione en filas nuevas.
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS shopping_lists_select ON karrito.shopping_lists;
DROP POLICY IF EXISTS shopping_lists_insert ON karrito.shopping_lists;
DROP POLICY IF EXISTS shopping_lists_update ON karrito.shopping_lists;
DROP POLICY IF EXISTS shopping_lists_delete ON karrito.shopping_lists;

CREATE POLICY shopping_lists_select ON karrito.shopping_lists
  FOR SELECT TO authenticated
  USING (owner_id = auth.uid() OR karrito.is_list_member(id) OR karrito.is_admin());

CREATE POLICY shopping_lists_insert ON karrito.shopping_lists
  FOR INSERT TO authenticated
  WITH CHECK ((owner_id = auth.uid() AND karrito.is_not_banned()) OR karrito.is_admin());

CREATE POLICY shopping_lists_update ON karrito.shopping_lists
  FOR UPDATE TO authenticated
  USING (
    ((owner_id = auth.uid() OR karrito.is_list_member(id)) AND karrito.is_not_banned())
    OR karrito.is_admin()
  )
  WITH CHECK (
    ((owner_id = auth.uid() OR karrito.is_list_member(id)) AND karrito.is_not_banned())
    OR karrito.is_admin()
  );

CREATE POLICY shopping_lists_delete ON karrito.shopping_lists
  FOR DELETE TO authenticated
  USING (owner_id = auth.uid() OR karrito.is_admin());

-- ---------------------------------------------------------------------------
-- 5. list_members (SELECT, INSERT, UPDATE, DELETE explícitos)
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS list_members_select ON karrito.list_members;
DROP POLICY IF EXISTS list_members_insert ON karrito.list_members;
DROP POLICY IF EXISTS list_members_update ON karrito.list_members;
DROP POLICY IF EXISTS list_members_delete ON karrito.list_members;

CREATE POLICY list_members_select ON karrito.list_members
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR karrito.is_list_member(list_id) OR karrito.is_admin());

CREATE POLICY list_members_insert ON karrito.list_members
  FOR INSERT TO authenticated
  WITH CHECK (
    (
      user_id = auth.uid()
      AND EXISTS (
        SELECT 1 FROM karrito.shopping_lists sl
        WHERE sl.id = list_members.list_id AND sl.owner_id = auth.uid()
      )
    )
    OR EXISTS (
      SELECT 1
      FROM karrito.shopping_lists sl
      JOIN karrito.users_profile up ON up.id = sl.owner_id
      WHERE sl.id = list_members.list_id
        AND sl.owner_id = auth.uid()
        AND up.plan_tier = 'pro_3usd'
    )
    OR karrito.is_admin()
  );

CREATE POLICY list_members_update ON karrito.list_members
  FOR UPDATE TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM karrito.shopping_lists sl
      WHERE sl.id = list_members.list_id AND sl.owner_id = auth.uid()
    )
    OR karrito.is_admin()
  )
  WITH CHECK (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM karrito.shopping_lists sl
      WHERE sl.id = list_members.list_id AND sl.owner_id = auth.uid()
    )
    OR karrito.is_admin()
  );

CREATE POLICY list_members_delete ON karrito.list_members
  FOR DELETE TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM karrito.shopping_lists sl
      WHERE sl.id = list_members.list_id AND sl.owner_id = auth.uid()
    )
    OR karrito.is_admin()
  );

-- ---------------------------------------------------------------------------
-- 6. list_items (SELECT, INSERT, UPDATE, DELETE explícitos)
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS list_items_all ON karrito.list_items;
DROP POLICY IF EXISTS list_items_select ON karrito.list_items;
DROP POLICY IF EXISTS list_items_insert ON karrito.list_items;
DROP POLICY IF EXISTS list_items_update ON karrito.list_items;
DROP POLICY IF EXISTS list_items_delete ON karrito.list_items;

CREATE POLICY list_items_select ON karrito.list_items
  FOR SELECT TO authenticated
  USING (karrito.is_list_member(list_id) OR karrito.is_admin());

CREATE POLICY list_items_insert ON karrito.list_items
  FOR INSERT TO authenticated
  WITH CHECK (
    (karrito.is_list_member(list_id) AND karrito.is_not_banned())
    OR karrito.is_admin()
  );

CREATE POLICY list_items_update ON karrito.list_items
  FOR UPDATE TO authenticated
  USING (
    (karrito.is_list_member(list_id) AND karrito.is_not_banned())
    OR karrito.is_admin()
  )
  WITH CHECK (
    (karrito.is_list_member(list_id) AND karrito.is_not_banned())
    OR karrito.is_admin()
  );

CREATE POLICY list_items_delete ON karrito.list_items
  FOR DELETE TO authenticated
  USING (
    (karrito.is_list_member(list_id) AND karrito.is_not_banned())
    OR karrito.is_admin()
  );

-- ---------------------------------------------------------------------------
-- 7. aisle_preferences (SELECT, INSERT, UPDATE, DELETE explícitos)
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS aisle_preferences_all ON karrito.aisle_preferences;
DROP POLICY IF EXISTS aisle_preferences_select ON karrito.aisle_preferences;
DROP POLICY IF EXISTS aisle_preferences_insert ON karrito.aisle_preferences;
DROP POLICY IF EXISTS aisle_preferences_update ON karrito.aisle_preferences;
DROP POLICY IF EXISTS aisle_preferences_delete ON karrito.aisle_preferences;

CREATE POLICY aisle_preferences_select ON karrito.aisle_preferences
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR karrito.is_admin());

CREATE POLICY aisle_preferences_insert ON karrito.aisle_preferences
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR karrito.is_admin());

CREATE POLICY aisle_preferences_update ON karrito.aisle_preferences
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid() OR karrito.is_admin())
  WITH CHECK (user_id = auth.uid() OR karrito.is_admin());

CREATE POLICY aisle_preferences_delete ON karrito.aisle_preferences
  FOR DELETE TO authenticated
  USING (user_id = auth.uid() OR karrito.is_admin());

-- ---------------------------------------------------------------------------
-- 8. learned_items (SELECT, INSERT, UPDATE, DELETE explícitos)
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS learned_items_all ON karrito.learned_items;
DROP POLICY IF EXISTS learned_items_select ON karrito.learned_items;
DROP POLICY IF EXISTS learned_items_insert ON karrito.learned_items;
DROP POLICY IF EXISTS learned_items_update ON karrito.learned_items;
DROP POLICY IF EXISTS learned_items_delete ON karrito.learned_items;

CREATE POLICY learned_items_select ON karrito.learned_items
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR karrito.is_admin());

CREATE POLICY learned_items_insert ON karrito.learned_items
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR karrito.is_admin());

CREATE POLICY learned_items_update ON karrito.learned_items
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid() OR karrito.is_admin())
  WITH CHECK (user_id = auth.uid() OR karrito.is_admin());

CREATE POLICY learned_items_delete ON karrito.learned_items
  FOR DELETE TO authenticated
  USING (user_id = auth.uid() OR karrito.is_admin());
