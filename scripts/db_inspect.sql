#!/bin/bash
set -e

echo "Fetching PostgreSQL schema and data..."

mkdir -p backup/db_inspect

# Save table list
psql "$DATABASE_URL" -At -c "\dt" > backup/db_inspect/table_list.txt
echo "Saved table list to backup/db_inspect/table_list.txt"

# Loop through all public tables and dump contents
TABLES=$(psql "$DATABASE_URL" -At -c "SELECT tablename FROM pg_tables WHERE schemaname='public';")

for t in $TABLES; do
  echo "Exporting table: $t"
  psql "$DATABASE_URL" -c "SELECT * FROM \"$t\";" > "backup/db_inspect/${t}_data.txt" 2>/dev/null || echo "Skipped $t"
done

echo "All table data exported to backup/db_inspect/"
