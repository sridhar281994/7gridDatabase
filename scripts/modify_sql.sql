#!/bin/bash
set -e

echo "===== Starting DB migration + inspection ====="

mkdir -p backup/db_inspect

OUTPUT_FILE="backup/db_inspect/full_db_data.txt"

# Clear previous output
> "$OUTPUT_FILE"

echo "=== STEP 1: Apply schema fixes ==="

# --------------------------------------------
# SAFE MIGRATIONS (Idempotent – can run daily)
# --------------------------------------------

psql "$DATABASE_URL" << 'EOF'

-- Add missing is_agent column
ALTER TABLE users 
    ADD COLUMN IF NOT EXISTS is_agent BOOLEAN DEFAULT FALSE;

-- Ensure refundable column exists with default true
ALTER TABLE matches 
    ADD COLUMN IF NOT EXISTS refundable BOOLEAN DEFAULT TRUE;

-- Ensure forfeit_ids column exists
ALTER TABLE matches
    ADD COLUMN IF NOT EXISTS forfeit_ids INTEGER[] DEFAULT '{}';

-- Ensure merchant_user_id exists
ALTER TABLE matches
    ADD COLUMN IF NOT EXISTS merchant_user_id INTEGER REFERENCES users(id);

EOF

echo "=== Migration complete ==="


echo "=== STEP 2: Start full DB inspection ==="

TABLES=$(psql "$DATABASE_URL" -At -c "SELECT tablename FROM pg_tables WHERE schemaname='public';")

for t in $TABLES; do
  echo "===== TABLE: $t =====" >> "$OUTPUT_FILE"
  
  # Describe table
  psql "$DATABASE_URL" -c "\d+ \"$t\"" >> "$OUTPUT_FILE" 2>/dev/null
  
  echo "" >> "$OUTPUT_FILE"
  
  # Dump table data
  psql "$DATABASE_URL" -c "SELECT * FROM \"$t\";" >> "$OUTPUT_FILE" 2>/dev/null \
    || echo "Skipped $t" >> "$OUTPUT_FILE"
  
  echo "" >> "$OUTPUT_FILE"
done

echo "✔ Full DB inspection written to $OUTPUT_FILE"
