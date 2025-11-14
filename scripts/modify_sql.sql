#!/bin/bash
set -e

echo "Starting DB inspection..."

# Validate
if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is missing"
  exit 1
fi

# Create output
OUT="backup/db_inspect/status_fix_$(date -u +%Y%m%d_%H%M%S).txt"
mkdir -p backup/db_inspect

# Run SQL commands using psql
psql "$DATABASE_URL" <<'EOF'
UPDATE matches SET status = 'WAITING'   WHERE status = 'waiting';
UPDATE matches SET status = 'ACTIVE'    WHERE status = 'active';
UPDATE matches SET status = 'FINISHED'  WHERE status = 'finished';
UPDATE matches SET status = 'ABANDONED' WHERE status = 'abandoned';
EOF

echo "Inspection complete" | tee "$OUT"
