#!/bin/bash
set -e

echo "Starting DB inspection..."

# Extract host / user / db / password from DATABASE_URL
# postgres://user:pass@host:5432/dbname
regex="postgres:\/\/([^:]+):([^@]+)@([^:\/]+):?([0-9]*)\/(.+)"
if [[ $DATABASE_URL =~ $regex ]]; then
  PGUSER="${BASH_REMATCH[1]}"
  PGPASSWORD="${BASH_REMATCH[2]}"
  PGHOST="${BASH_REMATCH[3]}"
  PGPORT="${BASH_REMATCH[4]:-5432}"
  PGDATABASE="${BASH_REMATCH[5]}"
else
  echo "Invalid DATABASE_URL"
  exit 1
fi

export PGPASSWORD

OUTDIR="backup/db_inspect"
mkdir -p "$OUTDIR"

# ----------------------------------------------------------------------
# Create / Replace VIEW
# ----------------------------------------------------------------------
psql "host=$PGHOST port=$PGPORT user=$PGUSER dbname=$PGDATABASE" <<'SQL'
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

echo "View created."

# ----------------------------------------------------------------------
# BEFORE COUNTS
# ----------------------------------------------------------------------
echo "Collecting BEFORE snapshot..."
psql "host=$PGHOST port=$PGPORT user=$PGUSER dbname=$PGDATABASE" -c \
"SELECT 'BEFORE' AS stage, status, COUNT(*) AS rows FROM matches GROUP BY status ORDER BY status;" \
> "$OUTDIR/01_before_status.txt"

# ----------------------------------------------------------------------
# Sample diagnostic query – Top 50 recent matches
# ----------------------------------------------------------------------
echo "Running diagnostic queries..."
psql "host=$PGHOST port=$PGPORT user=$PGUSER dbname=$PGDATABASE" -c \
"SELECT id, status, stake_amount, winner_user_id, created_at, finished_at
 FROM matches
 ORDER BY created_at DESC
 LIMIT 50;" \
> "$OUTDIR/02_recent_matches.txt"

# ----------------------------------------------------------------------
# AFTER COUNTS
# ----------------------------------------------------------------------
echo "Collecting AFTER snapshot (same as BEFORE, kept for consistency)..."
psql "host=$PGHOST port=$PGPORT user=$PGUSER dbname=$PGDATABASE" -c \
"SELECT 'AFTER' AS stage, status, COUNT(*) AS rows FROM matches GROUP BY status ORDER BY status;" \
> "$OUTDIR/03_after_status.txt"

echo "Inspection complete."
