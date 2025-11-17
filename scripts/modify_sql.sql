#!/bin/bash
set -e

echo "Starting PostgreSQL inspection and ROBOTS Army patch..."

mkdir -p backup/db_inspect

OUTPUT_FILE="backup/db_inspect/db_inspect_results.txt"
> "$OUTPUT_FILE"

echo "Ensuring ROBOTS Army exists in stakes table..." >> "$OUTPUT_FILE"

psql "$DATABASE_URL" <<'SQL' >> "$OUTPUT_FILE" 2>&1
DO $$
BEGIN
    -- Insert ROBOTS Army (2-player) into stakes table
    IF NOT EXISTS (
        SELECT 1 FROM stakes WHERE label = 'ROBOTS Army' AND players = 2
    ) THEN
        INSERT INTO stakes (stake_amount, entry_fee, winner_payout, players, label)
        VALUES (0, 0, 0, 2, 'ROBOTS Army');
        RAISE NOTICE 'Inserted ROBOTS Army (2P)';
    ELSE
        RAISE NOTICE 'ROBOTS Army (2P) already exists';
    END IF;

    -- Insert ROBOTS Army (3-player)
    IF NOT EXISTS (
        SELECT 1 FROM stakes WHERE label = 'ROBOTS Army' AND players = 3
    ) THEN
        INSERT INTO stakes (stake_amount, entry_fee, winner_payout, players, label)
        VALUES (0, 0, 0, 3, 'ROBOTS Army');
        RAISE NOTICE 'Inserted ROBOTS Army (3P)';
    ELSE
        RAISE NOTICE 'ROBOTS Army (3P) already exists';
    END IF;
END $$;
SQL

echo "ROBOTS Army stage patch applied." >> "$OUTPUT_FILE"

# Dump full DB
TABLES=$(psql "$DATABASE_URL" -At -c "SELECT tablename FROM pg_tables WHERE schemaname='public';")

for t in $TABLES; do
  echo "===== TABLE: $t =====" >> "$OUTPUT_FILE"
  psql "$DATABASE_URL" -c "\d+ \"$t\"" >> "$OUTPUT_FILE" 2>/dev/null
  echo "" >> "$OUTPUT_FILE"
  psql "$DATABASE_URL" -c "SELECT * FROM \"$t\";" >> "$OUTPUT_FILE" 2>/dev/null || echo "Skipped $t" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
done

echo "Inspection completed and saved to $OUTPUT_FILE"
