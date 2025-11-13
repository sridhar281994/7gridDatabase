#!/bin/bash
set -e

echo "Updating stakes table..."

psql "$DATABASE_URL" <<'SQL'

DROP TABLE IF EXISTS stakes;

CREATE TABLE stakes (
    id SERIAL PRIMARY KEY,
    stake_amount INTEGER NOT NULL,
    entry_fee INTEGER NOT NULL,
    winner_payout INTEGER NOT NULL,
    players INTEGER NOT NULL,
    label VARCHAR(50) NOT NULL
);

-- -------------------------
-- 2 PLAYER RULES
-- -------------------------
INSERT INTO stakes (stake_amount, entry_fee, winner_payout, players, label) VALUES
(0, 0, 0, 2, 'Free Play'),
(2, 2, 3, 2, 'Dual Rush'),
(4, 4, 6, 2, 'QUAD Crush'),
(6, 6, 9, 2, 'siXth Gear');

-- -------------------------
-- 3 PLAYER RULES
-- -------------------------
INSERT INTO stakes (stake_amount, entry_fee, winner_payout, players, label) VALUES
(0, 0, 0, 3, 'Free Play'),
(2, 2, 4, 3, 'Dual Rush'),
(4, 4, 8, 3, 'QUAD Crush'),
(6, 6, 12, 3, 'siXth Gear');

SQL

echo "Stakes table updated successfully."
