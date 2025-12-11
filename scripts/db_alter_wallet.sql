-- ============================================================
-- Add missing columns to wallet_transactions (safe/idempotent)
-- ============================================================

DO $$
BEGIN
    -- Add initiator_ip if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'wallet_transactions'
          AND column_name = 'initiator_ip'
    ) THEN
        ALTER TABLE public.wallet_transactions
        ADD COLUMN initiator_ip VARCHAR;
        RAISE NOTICE 'Added column initiator_ip';
    ELSE
        RAISE NOTICE 'Column initiator_ip already exists, skipping';
    END IF;

    -- Add extra_data if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'wallet_transactions'
          AND column_name = 'extra_data'
    ) THEN
        ALTER TABLE public.wallet_transactions
        ADD COLUMN extra_data JSONB DEFAULT '{}'::jsonb;
        RAISE NOTICE 'Added column extra_data';
    ELSE
        RAISE NOTICE 'Column extra_data already exists, skipping';
    END IF;

END $$;
