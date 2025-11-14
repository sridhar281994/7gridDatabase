#!/bin/bash
set -e

echo "Starting DB inspection..."

mkdir -p backup/db_inspect

OUTFILE="backup/db_inspect/match_inspect.txt"
> "$OUTFILE"

echo "Inspecting matches table..." | tee -a "$OUTFILE"

# 1. Basic match overview
echo -e "\n===== MATCH SUMMARY =====" >> "$OUTFILE"
psql "$DATABASE_URL" -c "
SELECT id, stake_amount, num_players, status, created_at, finished_at
FROM game_match
ORDER BY id DESC
LIMIT 200;
" >> "$OUTFILE" 2>/dev/null

# 2. Winner / loser distribution
echo -e "\n===== WINNER / LOSER CURRENT BALANCES =====" >> "$OUTFILE"
psql "$DATABASE_URL" -c "
SELECT 
    m.id AS match_id,
    m.stake_amount,
    u.id AS user_id,
    u.wallet_balance,
    CASE 
        WHEN m.winner_user_id = u.id THEN 'WINNER'
        ELSE 'LOSER'
    END AS result
FROM game_match m
LEFT JOIN users u 
    ON u.id = ANY(ARRAY[m.p1_user_id, m.p2_user_id, m.p3_user_id])
WHERE m.finished_at IS NOT NULL
ORDER BY m.id DESC
LIMIT 200;
" >> "$OUTFILE" 2>/dev/null

# 3. Recent prize distribution check
echo -e "\n===== PRIZE MOVEMENTS (LAST 24 HOURS) =====" >> "$OUTFILE"
psql "$DATABASE_URL" -c "
SELECT 
    t.id,
    t.user_id,
    t.amount,
    t.tx_type,
    t.status,
    t.timestamp
FROM wallet_transactions t
WHERE t.timestamp > NOW() - INTERVAL '1 day'
ORDER BY t.timestamp DESC;
" >> "$OUTFILE" 2>/dev/null

echo "DB inspection complete → $OUTFILE"
