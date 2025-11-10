#!/bin/bash
set -e

echo "Starting full PostgreSQL dump of all tables and columns..."

mkdir -p backup/db_inspect

OUTPUT_FILE="backup/db_inspect/full_db_data.txt"

# Clear previous file
> "$OUTPUT_FILE"

# Write table and column data in sequence
TABLES=$(psql "$DATABASE_URL" -At -c "SELECT tablename FROM pg_tables WHERE schemaname='public';")

for t in $TABLES; do
  echo "===== TABLE: $t =====" >> "$OUTPUT_FILE"
  psql "$DATABASE_URL" -c "\d+ \"$t\"" >> "$OUTPUT_FILE" 2>/dev/null
  echo "" >> "$OUTPUT_FILE"
  psql "$DATABASE_URL" -c "SELECT * FROM \"$t\";" >> "$OUTPUT_FILE" 2>/dev/null || echo "Skipped $t" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
done

echo "Full database data exported to $OUTPUT_FILE"
