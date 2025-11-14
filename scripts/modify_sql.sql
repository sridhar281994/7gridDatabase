#!/bin/bash
set -e

echo "Starting DB inspection..."

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set"
  exit 1
fi

mkdir -p backup/db_inspect
OUT="backup/db_inspect/status_fix_$(date -u +%Y%m%d_%H%M%S).txt"

# Run SQL with ENUM-safe comparisons
psql "$DATABASE_URL" <<'EOF'
-- Fix lowercase enum values by comparing as text
UPDATE matches SET status = 'WAITING'
WHERE status::text = 'waiting';

UPDATE matches SET status = 'ACTIVE'
WHERE status::text = 'active';

UPDATE matches SET status = 'FINISHED'
WHERE status::text = 'finished';

UPDATE matches SET status = 'ABANDONED'
WHERE status::text = 'abandoned';
EOF

echo "Inspection complete" | tee "$OUT"
