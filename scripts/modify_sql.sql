#!/bin/bash
set -e

echo "Adding Free Play stage to stakes table..."

psql "$DATABASE_URL" <<'SQL'
-- ====================================
-- Ensure Free Play stage exists
-- ====================================
INSERT INTO stakes (stake_amount, entry_fee, winner_payout, label)
VALUES (0, 0, 0, 'Free Play')
ON CONFLICT (stake_amount)
DO UPDATE SET
    entry_fee = EXCLUDED.entry_fee,
    winner_payout = EXCLUDED.winner_payout,
    label = EXCLUDED.label;

-- Confirm result
SELECT stake_amount, entry_fee, winner_payout, label
FROM stakes
ORDER BY stake_amount;
SQL

echo "✅ Free Play stage added successfully!"
