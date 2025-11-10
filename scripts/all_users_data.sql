#!/bin/bash
set -e

echo "Exporting all users data from PostgreSQL..."

mkdir -p backup/db_inspect

OUTPUT_FILE="backup/db_inspect/all_users_data.txt"

# Clear previous file
> "$OUTPUT_FILE"

# Header
echo "===== USERS TABLE DATA =====" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Table structure
psql "$DATABASE_URL" -c "\d+ users" >> "$OUTPUT_FILE" 2>/dev/null
echo "" >> "$OUTPUT_FILE"

# Full user data with selected columns
psql "$DATABASE_URL" -F $'\t' -A -c \
"SELECT id, phone, email, password_hash, name, upi_id, description, wallet_balance, profile_image, created_at, updated_at FROM users ORDER BY id;" \
>> "$OUTPUT_FILE" 2>/dev/null

echo "" >> "$OUTPUT_FILE"
echo "✅ All user data exported to $OUTPUT_FILE"
