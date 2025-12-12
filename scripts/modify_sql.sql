#!/bin/bash
set -e

echo "Updating agent names to global-friendly names (60% Indian, 40% International)..."

mkdir -p backup/db_inspect
OUTPUT_FILE="backup/db_inspect/agent_name_update_log.txt"

psql "$DATABASE_URL" <<'SQL'
DO $$
BEGIN
    -- ============================
    -- Indian Names (60%)
    -- ============================

    UPDATE public.users SET name = 'Aarav Sharma' WHERE id = 10001 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Priya Nair' WHERE id = 10003 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Rohan Mehta' WHERE id = 10004 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Kavya Iyer' WHERE id = 10006 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Aditya Verma' WHERE id = 10007 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Neha Reddy' WHERE id = 10008 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Suresh Babu' WHERE id = 10009 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Ananya Singh' WHERE id = 10010 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Karthik Menon' WHERE id = 10011 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Sneha Patil' WHERE id = 10012 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Varun Shetty' WHERE id = 10013 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Meera Joshi' WHERE id = 10014 AND name LIKE 'Agent%';

    -- ============================
    -- International Names (40%)
    -- ============================

    UPDATE public.users SET name = 'Daniel Costa' WHERE id = 10017 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Mia Svensson' WHERE id = 10018 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Jacob Müller' WHERE id = 10019 AND name LIKE 'Agent%';
    UPDATE public.users SET name = 'Layla Ibrahim' WHERE id = 10020 AND name LIKE 'Agent%';

END $$;
SQL

echo "Agent name updates completed successfully."

echo "Exporting updated agent list..."

psql "$DATABASE_URL" -c \
"SELECT id, phone, email, name, wallet_balance FROM public.users WHERE id BETWEEN 10000 AND 10020 ORDER BY id;" \
> "$OUTPUT_FILE"

echo "Export completed: $OUTPUT_FILE"
