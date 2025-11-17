#!/bin/bash
set -e

# Echo message to indicate script start
echo "Starting full PostgreSQL inspection and schema fixes..."

# Create directories to store inspection artifacts
mkdir -p backup/db_inspect

# Output file for database inspection
OUTPUT_FILE="backup/db_inspect/full_db_data.txt"

# Clear the previous inspection file if it exists
> "$OUTPUT_FILE"

# Write table and column data in sequence
TABLES=$(psql "$DATABASE_URL" -At -c "SELECT tablename FROM pg_tables WHERE schemaname='public';")

# Loop through each table and gather schema and data
for t in $TABLES; do
  echo "===== TABLE: $t =====" >> "$OUTPUT_FILE"
  # Describe the table schema
  psql "$DATABASE_URL" -c "\d+ \"$t\"" >> "$OUTPUT_FILE" 2>/dev/null
  echo "" >> "$OUTPUT_FILE"
  # Select all data from the table
  psql "$DATABASE_URL" -c "SELECT * FROM \"$t\";" >> "$OUTPUT_FILE" 2>/dev/null || echo "Skipped $t" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
done

echo "Full database data exported to $OUTPUT_FILE"

# -----------------------------
# Handle Schema Updates (example)
# -----------------------------
echo "Checking if schema needs updates..."

# If you need to add a column or fix missing columns like `is_agent` for 'users' table
psql "$DATABASE_URL" <<EOF
-- Add 'is_agent' column if it doesn't exist
ALTER TABLE IF EXISTS users
ADD COLUMN IF NOT EXISTS is_agent BOOLEAN DEFAULT FALSE;

-- You can add other schema fixes or data updates here
EOF

echo "Schema updates completed."

# Optionally, update specific data or fix issues if needed
# Example: Update all agent users if needed
psql "$DATABASE_URL" <<EOF
-- Example: Update bot users to be marked as agents
UPDATE users SET is_agent = TRUE WHERE id IN (-1000, -1001, -1002);
EOF

echo "Schema and data updates completed."

# Final message indicating completion
echo "PostgreSQL inspection and updates finished."
