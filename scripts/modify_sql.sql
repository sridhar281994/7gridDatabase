#!/bin/bash
set -e

# Create directory to store inspection results
mkdir -p backup/db_inspect

# Set output file path for inspection results
OUTPUT_FILE="backup/db_inspect/full_db_data.txt"

# Clear any previous output
> "$OUTPUT_FILE"

# Retrieve all tables in the public schema
TABLES=$(psql "$DATABASE_URL" -At -c "SELECT tablename FROM pg_tables WHERE schemaname='public';")

# Loop through each table and retrieve details and data
for t in $TABLES; do
  echo "===== TABLE: $t =====" >> "$OUTPUT_FILE"

  # Get table structure (columns, types, constraints)
  psql "$DATABASE_URL" -c "\d+ \"$t\"" >> "$OUTPUT_FILE" 2>/dev/null
  echo "" >> "$OUTPUT_FILE"

  # Get all data from the table (or skip if an error occurs)
  psql "$DATABASE_URL" -c "SELECT * FROM \"$t\";" >> "$OUTPUT_FILE" 2>/dev/null || echo "Skipped $t" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
done

# Final message indicating where the data has been saved
echo "Full database data exported to $OUTPUT_FILE"
