#!/bin/bash
set -e

echo "Exporting all users data (column formatted)..."

mkdir -p backup/db_inspect

OUTPUT_FILE="backup/db_inspect/all_users_data.txt"

# Clear previous file
> "$OUTPUT_FILE"

# Export table in aligned, readable format with headers
psql "$DATABASE_URL" -c "\x on; \
SELECT id, phone, email, password_hash, name, upi_id, description, wallet_balance, profile_image, created_at, updated_at \
FROM users ORDER BY id;" >> "$OUTPUT_FILE" 2>/dev/null

echo "✅ User data exported to $OUTPUT_FILE"
