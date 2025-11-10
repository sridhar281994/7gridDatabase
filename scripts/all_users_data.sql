#!/bin/bash
set -e

echo "Fetching user table data..."

mkdir -p backup/db_inspect
OUTPUT_FILE="backup/db_inspect/users_data.txt"

# Clear previous file
> "$OUTPUT_FILE"

# Query with selected columns and aligned output
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -P footer=off -P "format=aligned" -c "
SELECT 
  id,
  phone,
  email,
  password_hash,
  name,
  upi_id,
  description,
  wallet_balance,
  profile_image,
  created_at,
  updated_at
FROM users
ORDER BY id;
" > "$OUTPUT_FILE"

echo "✅ Users table exported to $OUTPUT_FILE"
