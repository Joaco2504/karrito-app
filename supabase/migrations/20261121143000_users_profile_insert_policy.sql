-- Allow authenticated users to self-create their missing karrito.users_profile row
-- (for pre-existing auth.users accounts) without allowing privilege escalation.
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
      WITH CHECK (
        id = auth.uid()
        AND plan_tier = 'free'
        AND is_banned = false
      );
  END IF;
END
$$;

-- Backfill any auth.users accounts that existed prior to the Karrito signup trigger.
INSERT INTO "karrito"."users_profile" (id, email)
SELECT u.id, u.email
FROM auth.users u
LEFT JOIN "karrito"."users_profile" p ON p.id = u.id
WHERE p.id IS NULL
ON CONFLICT (id) DO NOTHING;
