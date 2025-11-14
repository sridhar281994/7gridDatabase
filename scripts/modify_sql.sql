#!/bin/bash
set -e

echo "Starting DB inspection..."

# Run SQL using psql
psql "$DATABASE_URL" <<'SQL'

-- ===============================
-- 1. Create table if not exists
-- ===============================
CREATE TABLE IF NOT EXISTS match_results (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL,
    winner_id INTEGER NOT NULL,
    loser_ids INTEGER[] NOT NULL,
    stake_amount INTEGER NOT NULL,
    num_players INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ===============================
-- 2. Create indexes
-- ===============================
CREATE INDEX IF NOT EXISTS idx_match_results_match_id
    ON match_results(match_id);

CREATE INDEX IF NOT EXISTS idx_match_results_winner
    ON match_results(winner_id);

-- ===============================
-- 3. Export sample inspection data
-- ===============================
\copy (
    SELECT
        m.id AS match_id,
        m.stake_amount,
        m.num_players,
        m.winner_user_id AS winner,
        ARRAY_REMOVE(ARRAY[m.p1_user_id, m.p2_user_id, m.p3_user_id], m.winner_user_id) AS losers,
        m.created_at,
        m.finished_at
    FROM matches m
    WHERE m.status = 'FINISHED'
    ORDER BY m.id DESC
    LIMIT 50
) TO 'backup/db_inspect/match_results.txt' WITH CSV HEADER;

SQL

echo "Inspection complete."
