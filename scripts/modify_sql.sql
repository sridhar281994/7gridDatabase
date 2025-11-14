#!/bin/bash
set -e

echo "Starting DB inspection..."

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set"
  exit 1
fi

mkdir -p backup/db_inspect
OUT="backup/db_inspect/status_fix_$(date -u +%Y%m%d_%H%M%S).txt"

# Perform updates + collect counts
psql "$DATABASE_URL" <<'EOF' > "$OUT"

-- Show current enum values before changes
SELECT 'BEFORE' AS stage, status, COUNT(*) AS rows
FROM matches
GROUP BY status
ORDER BY status;

-- Fix lowercase enum values
UPDATE matches SET status = 'WAITING'
WHERE status::text = 'waiting';

UPDATE matches SET status = 'ACTIVE'
WHERE status::text = 'active';

UPDATE matches SET status = 'FINISHED'
WHERE status::text = 'finished';

UPDATE matches SET status = 'ABANDONED'
WHERE status::text = 'abandoned';

-- Show status distribution after change
SELECT 'AFTER' AS stage, status, COUNT(*) AS rows
FROM matches
GROUP BY status
ORDER BY status;

EOF

echo "Inspection complete. Report saved to $OUT"
