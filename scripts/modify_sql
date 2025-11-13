#!/bin/bash
set -e

echo "Updating stakes table with new stake logic (2, 4, 6) ..."

mkdir -p backup/db_inspect

OUTPUT_FILE="backup/db_inspect/stakes_update_log.txt"
> "$OUTPUT_FILE"

psql "$DATABASE_URL" <<'SQL' >> "$OUTPUT_FILE"

-- Remove old stake rules
TRUNCATE TABLE stakes RESTART IDENTITY;

-- 3-player mode stakes
INSERT INTO stakes (stake_amount, entry_fee, winner_payout, label) VALUES
(2, 2, 4, '₹2 Stage (3-player)'),
(4, 4, 8, '₹4 Stage (3-player)'),
(6, 6, 12, '₹6 Stage (3-player)');

-- 2-player mode stakes
INSERT INTO stakes (stake_amount, entry_fee, winner_payout, label) VALUES
(2, 2, 3, '₹2 Stage (2-player)'),
(4, 4, 6, '₹4 Stage (2-player)'),
(6, 6, 9, '₹6 Stage (2-player)');

-- Verify insertion
SELECT id, stake_amount, entry_fee, winner_payout, label FROM stakes ORDER BY id;

SQL

echo "Stake table updated successfully and verified." >> "$OUTPUT_FILE"
echo "Script completed. Output saved to $OUTPUT_FILE"
