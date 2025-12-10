-- ============================================================
-- Add missing column: initiator_ip to wallet_transactions
-- Safe migration (idempotent)
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'wallet_transactions'
          AND column_name = 'initiator_ip'
    ) THEN
        ALTER TABLE public.wallet_transactions
        ADD COLUMN initiator_ip VARCHAR;
    END IF;
END $$;
