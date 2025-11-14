#!/bin/bash
set -e

echo "Starting DB inspection..."

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is missing"
  exit 1
fi

OUT="backup/db_inspect/status_fix_$(date -u +%Y%m%d_%H%M%S).txt"
mkdir -p backup/db_inspect

# Run SQL fixes
psql "$DATABASE_URL" <<'EOF'
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
