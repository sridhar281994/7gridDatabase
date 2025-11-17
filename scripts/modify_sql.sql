#!/bin/bash
set -e

echo "Starting PostgreSQL inspection and modification..."

# Create necessary directories
mkdir -p backup/db_inspect scripts

OUTPUT_FILE="backup/db_inspect/db_inspect_results.txt"

# Clear previous file
> "$OUTPUT_FILE"

# Inspect and modify 'stages' table for 'ROBOTS Army' stage (2-player & 3-player)
echo "Checking and adding 'ROBOTS Army' stages if not exists..." >> "$OUTPUT_FILE"

# SQL to add ROBOTS Army stage (for both 2-player and 3-player)
psql "$DATABASE_URL" -c "
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM stages WHERE label = 'ROBOTS Army' AND players = 2) THEN
        INSERT INTO stages (stake_amount, entry_fee, winner_payout, players, label)
        VALUES (0, 0, 0, 2, 'ROBOTS Army');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM stages WHERE label = 'ROBOTS Army' AND players = 3) THEN
        INSERT INTO stages (stake_amount, entry_fee, winner_payout, players, label)
        VALUES (0, 0, 0, 3, 'ROBOTS Army');
    END IF;
END \$\$;
" >> "$OUTPUT_FILE" 2>/dev/null

echo "Stage inspection and modification completed." >> "$OUTPUT_FILE"

# Write table and column data in sequence
TABLES=$(psql "$DATABASE_URL" -At -c "SELECT tablename FROM pg_tables WHERE schemaname='public';")

for t in $TABLES; do
  echo "===== TABLE: $t =====" >> "$OUTPUT_FILE"
  psql "$DATABASE_URL" -c "\d+ \"$t\"" >> "$OUTPUT_FILE" 2>/dev/null
  echo "" >> "$OUTPUT_FILE"
  psql "$DATABASE_URL" -c "SELECT * FROM \"$t\";" >> "$OUTPUT_FILE" 2>/dev/null || echo "Skipped $t" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
done

echo "Full database inspection completed. Data exported to $OUTPUT_FILE"
