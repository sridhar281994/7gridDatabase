#!/bin/bash
set -e

echo "Updating stage names (labels) in stakes table..."

psql "$DATABASE_URL" <<'SQL'
-- ============================
-- Update Stage Labels
-- ============================

UPDATE stakes
SET label = 'Dual Rush'
WHERE stake_amount = 2;

UPDATE stakes
SET label = 'QUAD Crush'
WHERE stake_amount = 4;

UPDATE stakes
SET label = 'siXth Gear'
WHERE stake_amount = 6;

-- Optional: confirm results
SELECT stake_amount, label FROM stakes ORDER BY stake_amount;
SQL

echo "✅ Stage labels updated successfully!"
