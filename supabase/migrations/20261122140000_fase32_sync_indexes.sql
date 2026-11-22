-- Fase 3.2: Ensure users_profile INSERT RLS policy and delta-sync indexes on karrito schema.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'karrito'
      AND tablename = 'users_profile'
      AND policyname = 'users_profile_insert'
  ) THEN
    CREATE POLICY "users_profile_insert"
      ON "karrito"."users_profile"
      FOR INSERT
      WITH CHECK (id = auth.uid());
  END IF;
END
$$;

-- Composite indexes to accelerate incremental delta sync queries (.gte('updated_at', lastSyncedAt))
CREATE INDEX IF NOT EXISTS idx_aisle_preferences_user_updated
  ON "karrito"."aisle_preferences" (user_id, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_learned_items_user_updated
  ON "karrito"."learned_items" (user_id, updated_at DESC);
