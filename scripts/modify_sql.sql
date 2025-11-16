#!/bin/bash
set -e

echo "Starting DB inspection..."

mkdir -p backup/db_inspect

OUT_BEFORE="backup/db_inspect/01_before_status.txt"
OUT_AFTER="backup/db_inspect/03_after_status.txt"
OUT_RECENT="backup/db_inspect/02_recent_matches.txt"

# Clear old files
> "$OUT_BEFORE"
> "$OUT_AFTER"
> "$OUT_RECENT"

# -------------------------------------------------------
# Create / Replace match_details VIEW
# -------------------------------------------------------
echo "Creating/Updating match_details view..."

psql "$DATABASE_URL" <<'SQL'
CREATE OR REPLACE VIEW match_details AS
SELECT
  m.id,
  m.stake_amount,
  COALESCE(u1.name, CONCAT('User-', m.p1_user_id)) AS player1,
  COALESCE(u2.name, CONCAT('User-', m.p2_user_id)) AS player2,
  COALESCE(u3.name, CONCAT('User-', m.p3_user_id)) AS player3,
  uw.name AS winner,
  um.name AS merchant,
  m.status,
  m.system_fee,
  m.created_at,
  m.finished_at,
  m.current_turn,
  m.num_players,
  m.refundable,
  m.forfeit_ids
FROM matches m
LEFT JOIN users u1 ON m.p1_user_id = u1.id
LEFT JOIN users u2 ON m.p2_user_id = u2.id
LEFT JOIN users u3 ON m.p3_user_id = u3.id
LEFT JOIN users uw ON m.winner_user_id = uw.id
LEFT JOIN users um ON m.merchant_user_id = um.id;
SQL

echo "View creation complete."

# -------------------------------------------------------
# BEFORE snapshot
# -------------------------------------------------------
echo "Collecting BEFORE status counts..."
psql "$DATABASE_URL" -c \
"SELECT 'BEFORE' AS stage, status, COUNT(*) AS rows
 FROM matches
 GROUP BY status
 ORDER BY status;" \
> "$OUT_BEFORE"

# -------------------------------------------------------
# Diagnostic query – Recent matches
# -------------------------------------------------------
echo "Collecting recent match diagnostics..."
psql "$DATABASE_URL" -c \
"SELECT id, status, stake_amount, winner_user_id, created_at, finished_at
 FROM matches
 ORDER BY created_at DESC
 LIMIT 50;" \
> "$OUT_RECENT"

# -------------------------------------------------------
# AFTER snapshot
# -------------------------------------------------------
echo "Collecting AFTER status counts..."
psql "$DATABASE_URL" -c \
"SELECT 'AFTER' AS stage, status, COUNT(*) AS rows
 FROM matches
 GROUP BY status
 ORDER BY status;" \
> "$OUT_AFTER"

echo "Inspection complete. Files saved in backup/db_inspect/"
