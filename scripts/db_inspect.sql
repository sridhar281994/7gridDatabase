#!/bin/bash
set -e

echo "Starting PostgreSQL inspection..."

mkdir -p backup/db_inspect

# Save list of all tables
psql "$DATABASE_URL" -At -c "\dt" > backup/db_inspect/table_list.txt
echo "Saved table list to backup/db_inspect/table_list.txt"

# Fetch all public tables
TABLES=$(psql "$DATABASE_URL" -At -c "SELECT tablename FROM pg_tables WHERE schemaname='public';")

# Dump each table’s data into its own file
for t in $TABLES; do
  echo "Exporting table: $t"
  psql "$DATABASE_URL" -c "TABLE \"$t\";" > "backup/db_inspect/${t}_data.txt" 2>/dev/null || echo "Skipped $t"
done

echo "Database inspection completed."
