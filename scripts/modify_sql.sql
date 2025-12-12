#!/bin/bash
set -e

echo "Updating agent names to global-friendly names (Indian & International) ..."

mkdir -p backup/db_inspect
OUTPUT_FILE="backup/db_inspect/agent_name_update_log.txt"

psql "$DATABASE_URL" <<'SQL'
DO $$
BEGIN
    -- ============================
    -- Indian Names (subset updated)
    -- ============================

    UPDATE public.users SET name = 'Arjun Mehta' WHERE id = 10002 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Sneha Iyer' WHERE id = 10005 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Rohit Kulkarni' WHERE id = 10015 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Priya Desai' WHERE id = 10016 AND name LIKE 'Agent%';

    -- ============================
    -- (Other Indian / International names remain as needed)
    -- ============================

END $$;
SQL

echo "Agent name updates completed successfully."

echo "Exporting updated agent list..."

psql "$DATABASE_URL" -c \
"SELECT id, phone, email, name, wallet_balance FROM public.users WHERE id BETWEEN 10000 AND 10020 ORDER BY id;" \
> "$OUTPUT_FILE"

echo "Export completed: $OUTPUT_FILE"
