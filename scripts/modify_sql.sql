#!/bin/bash
set -e

echo "Starting DB inspection..."

# Extract psql connection pieces from DATABASE_URL
export PGHOST=$(echo "$DATABASE_URL" | sed -E 's|.*://([^:/]+).*|\1|')
export PGPORT=$(echo "$DATABASE_URL" | sed -E 's|.*:([0-9]+)/.*|\1|')
export PGUSER=$(echo "$DATABASE_URL" | sed -E 's|.*//([^:]+):.*|\1|')
export PGPASSWORD=$(echo "$DATABASE_URL" | sed -E 's|.*:([^@]+)@.*|\1|')
export PGDATABASE=$(echo "$DATABASE_URL" | sed -E 's|.*/([^/?]+).*|\1|')

echo "Running SQL..."

psql <<'SQL'
CREATE TABLE IF NOT EXISTS match_inspection (
    id SERIAL PRIMARY KEY,
    match_id INT,
    stake_amount INT,
    num_players INT,
    status TEXT,
    created_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    winner_user_id INT
);

DELETE FROM match_inspection;

INSERT INTO match_inspection (match_id, stake_amount, num_players, status, created_at, finished_at, winner_user_id)
SELECT 
    id,
    stake_amount,
    num_players,
    status,
    created_at,
    finished_at,
    winner_user_id
FROM matches;
SQL

echo "Exporting CSV..."
psql -c "\copy match_inspection TO 'backup/db_inspect/match_inspect.csv' CSV HEADER"

echo "Inspection Complete."
