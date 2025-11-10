#!/bin/bash
set -e

echo "Fetching match details with player names..."

mkdir -p backup/db_inspect

OUTPUT_FILE="backup/db_inspect/matches_data_with_names.txt"

# Run SQL join query and save output
psql "$DATABASE_URL" -c "
SELECT
  m.id,
  m.stake_amount,
  u1.name AS p1_name,
  u2.name AS p2_name,
  u3.name AS p3_name,
  uw.name AS winner_name,
  um.name AS merchant_name,
  m.status,
  m.system_fee,
  m.created_at,
  m.finished_at,
  m.last_roll,
  m.current_turn,
  m.num_players,
  m.refundable,
  m.forfeit_ids
FROM matches_data m
LEFT JOIN users u1 ON m.p1_user_id = u1.id
LEFT JOIN users u2 ON m.p2_user_id = u2.id
LEFT JOIN users u3 ON m.p3_user_id = u3.id
LEFT JOIN users uw ON m.winner_user_id = uw.id
LEFT JOIN users um ON m.merchant_user_id = um.id
ORDER BY m.id DESC;
" > "$OUTPUT_FILE"

echo "Match data with names exported to $OUTPUT_FILE"
