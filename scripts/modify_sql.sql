#!/bin/bash
set -e

echo "Starting PostgreSQL inspection and modification..."

# Create necessary directories
mkdir -p backup/db_inspect scripts

OUTPUT_FILE="backup/db_inspect/db_inspect_results.txt"

# Clear previous file
> "$OUTPUT_FILE"

# Ensure 'stages' table exists
echo "Ensuring 'stages' table exists..." >> "$OUTPUT_FILE"
psql "$DATABASE_URL" <<EOF >> "$OUTPUT_FILE" 2>&1
-- SQL Script to Ensure 'stages' Table and Modify Database for 'ROBOTS Army' Stage

-- Create 'stages' table if it doesn't exist
CREATE TABLE IF NOT EXISTS stages (
    id SERIAL PRIMARY KEY,
    stake_amount INT,
    entry_fee INT,
    winner_payout INT,
    players INT,
    label VARCHAR(255)
);

-- Now modify the 'stages' table for 'ROBOTS Army'
DO \$\$
BEGIN
    -- Check if 'ROBOTS Army' exists for 2 players
    RAISE NOTICE 'Checking if ROBOTS Army (2-player) exists...';
    IF NOT EXISTS (SELECT 1 FROM stages WHERE label = 'ROBOTS Army' AND players = 2) THEN
        RAISE NOTICE 'Inserting ROBOTS Army (2-player)...';
        INSERT INTO stages (stake_amount, entry_fee, winner_payout, players, label)
        VALUES (0, 0, 0, 2, 'ROBOTS Army');
    ELSE
        RAISE NOTICE 'ROBOTS Army (2-player) already exists.';
    END IF;

    -- Check if 'ROBOTS Army' exists for 3 players
    RAISE NOTICE 'Checking if ROBOTS Army (3-player) exists...';
    IF NOT EXISTS (SELECT 1 FROM stages WHERE label = 'ROBOTS Army' AND players = 3) THEN
        RAISE NOTICE 'Inserting ROBOTS Army (3-player)...';
        INSERT INTO stages (stake_amount, entry_fee, winner_payout, players, label)
        VALUES (0, 0, 0, 3, 'ROBOTS Army');
    ELSE
        RAISE NOTICE 'ROBOTS Army (3-player) already exists.';
    END IF;
END \$\$;
EOF

echo "Stage inspection and modification completed." >> "$OUTPUT_FILE"

# Inspect all tables and export data
TABLES=$(psql "$DATABASE_URL" -At -c "SELECT tablename FROM pg_tables WHERE schemaname='public';")

for t in $TABLES; do
  echo "===== TABLE: $t =====" >> "$OUTPUT_FILE"
  psql "$DATABASE_URL" -c "\d+ \"$t\"" >> "$OUTPUT_FILE" 2>/dev/null
  echo "" >> "$OUTPUT_FILE"
  psql "$DATABASE_URL" -c "SELECT * FROM \"$t\";" >> "$OUTPUT_FILE" 2>/dev/null || echo "Skipped $t" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
done

echo "Full database inspection completed. Data exported to $OUTPUT_FILE"
