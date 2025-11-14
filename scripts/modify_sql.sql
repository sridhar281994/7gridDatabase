#!/bin/bash
set -e

echo "Starting DB inspection..."

mkdir -p backup/db_inspect

OUT="backup/db_inspect/match_inspect.txt"
> "$OUT"

echo "Inspecting matches table..." >> "$OUT"

# 1. Check if table exists
EXISTS=$(psql "$DATABASE_URL" -tAc "SELECT to_regclass('public.matches');")

if [ "$EXISTS" = "matches" ]; then
  echo "Table found → dumping data..." >> "$OUT"

  # 2. Dump match summary
  psql "$DATABASE_URL" -c "
    SELECT 
      id,
      stake_amount,
      num_players,
      status,
      p1_user_id,
      p2_user_id,
      p3_user_id,
      winner_user_id,
      created_at,
      finished_at
    FROM matches
    ORDER BY id DESC
    LIMIT 200;
  " >> "$OUT" 2>/dev/null || echo "Failed to query matches" >> "$OUT"

else
  echo "matches table NOT found." >> "$OUT"
fi

echo "" >> "$OUT"
echo "Inspection complete." >> "$OUT"

echo "Inspection written to $OUT"
