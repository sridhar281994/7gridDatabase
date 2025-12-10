#!/bin/bash
set -e

echo "Starting wallet_transactions table patch…"

mkdir -p backup/db_inspect

OUTPUT_FILE="backup/db_inspect/wallet_transactions_structure_after_patch.txt"

# ---------------------------------------------
# Apply ALTER TABLE migration
# ---------------------------------------------
psql "$DATABASE_URL" <<'SQL'
DO $$
BEGIN
    -- Only add column if it doesn't already exist
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name='wallet_transactions'
          AND column_name='initiator_ip'
    ) THEN
        ALTER TABLE public.wallet_transactions
        ADD COLUMN initiator_ip VARCHAR;
    END IF;
END $$;
SQL

echo "Patch applied. Dumping new table structure…"

# ---------------------------------------------
# Export updated table structure for verification
# ---------------------------------------------
psql "$DATABASE_URL" -c "\d+ public.wallet_transactions" > "$OUTPUT_FILE"

echo "Export completed: $OUTPUT_FILE"
echo "wallet_transactions ALTER TABLE migration successful."
