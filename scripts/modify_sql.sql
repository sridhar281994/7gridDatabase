#!/bin/bash
set -ex  # Enable command tracing for debugging

echo "Starting PostgreSQL inspection and modification..."

# Create necessary directories
mkdir -p backup/db_inspect scripts

OUTPUT_FILE="backup/db_inspect/db_inspect_results.txt"

# Clear previous file
> "$OUTPUT_FILE"

# Inspect and modify 'stages' table for 'ROBOTS Army' stage (2-player & 3-player)
echo "Checking and adding 'ROBOTS Army' stages if not exists..." >> "$OUTPUT_FILE"

# SQL to add ROBOTS Army stage (for both 2-player and 3-player)
psql "$DATABASE_URL" <<EOF
DO \$\$
BEGIN
    -- Log the process of checking and inserting stages
    RAISE NOTICE 'Checking for ROBOTS Army (2-player)...';
    
    IF NOT EXISTS (SELECT 1 FROM stages WHERE label = 'ROBOTS Army' AND players = 2) THEN
        RAISE NOTICE 'Inserting ROBOTS Army stage (2-player)...';
        INSERT INTO stages (stake_amount, entry_fee, winner_payout, players, label)
        VALUES (0, 0, 0, 2, 'ROBOTS Army');
    ELSE
        RAISE NOTICE 'ROBOTS Army (2-player) already exists.';
    END IF;
    
    RAISE NOTICE 'Checking for ROBOTS Army (3-player)...';
    
    IF NOT EXISTS (SELECT 1 FROM stages WHERE label = 'ROBOTS Army' AND players = 3) THEN
        RAISE NOTICE 'Inserting ROBOTS Army stage (3-player)...';
        INSERT INTO stages (stake_amount, entry_fee, winner_payout, players, label)
        VALUES (0, 0, 0, 3, 'ROBOTS Army');
    ELSE
        RAISE NOTICE 'ROBOTS Army (3-player) already exists.';
    END IF;
END \$\$;
EOF

echo "Stage inspection and modification completed." >> "$OUTPUT_FILE"

# Write table and column data in sequence
TABLES=$(psql "$DATABASE_URL" -At -c "SELECT tablename FROM pg_tables WHERE schemaname='public';")

for t in $TABLES; do
  echo "===== TABLE: $t =====" >> "$OUTPUT_FILE"
  psql "$DATABASE_URL" -c "\d+ \"$t\"" >> "$OUTPUT_FILE" 2>&1  # Capturing stderr too
  echo "" >> "$OUTPUT_FILE"
  psql "$DATABASE_URL" -c "SELECT * FROM \"$t\";" >> "$OUTPUT_FILE" 2>&1 || echo "Skipped $t" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
done

echo "Full database inspection completed. Data exported to $OUTPUT_FILE"
