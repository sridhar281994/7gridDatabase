#!/bin/bash
set -e

echo "Running SQL fix on matches table..."

# Execute SQL inside PostgreSQL
psql "$DATABASE_URL" << 'EOF'
-- Safe to run multiple times

UPDATE matches SET status = 'WAITING'   
WHERE status = 'waiting';

UPDATE matches SET status = 'ACTIVE'    
WHERE status = 'active';

UPDATE matches SET status = 'FINISHED'  
WHERE status = 'finished';

UPDATE matches SET status = 'ABANDONED' 
WHERE status = 'abandoned';

-- Output last 50 rows for inspection
SELECT id, status 
FROM matches 
ORDER BY id DESC 
LIMIT 50;
EOF

echo "SQL patch completed. Writing inspection output..."

# Save inspection result to artifact folder
mkdir -p backup/db_inspect
psql "$DATABASE_URL" -c "SELECT id, status FROM matches ORDER BY id DESC" \
  > backup/db_inspect/status_report.txt

echo "Inspection file saved at backup/db_inspect/status_report.txt"
