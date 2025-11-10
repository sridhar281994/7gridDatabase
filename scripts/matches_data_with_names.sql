#!/bin/bash
set -e

echo "Creating or replacing match_details view and exporting results..."

mkdir -p backup/db_inspect

OUTPUT_FILE="backup/db_inspect/matches_data_with_names.txt"

psql "$DATABASE_URL" <<'SQL'
CREATE OR REPLACE VIEW public.match_details AS
SELECT
  m.id,
  m.stake_amount,
  COALESCE(u1.name, 'User-' || m.p1_user_id::text) AS player1,
  COALESCE(u2.name, 'User-' || m.p2_user_id::text) AS player2,
  COALESCE(u3.name, 'User-' || m.p3_user_id::text) AS player3,
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
FROM public.matches AS m
LEFT JOIN public.users AS u1 ON m.p1_user_id = u1.id
LEFT JOIN public.users AS u2 ON m.p2_user_id = u2.id
LEFT JOIN public.users AS u3 ON m.p3_user_id = u3.id
LEFT JOIN public.users AS uw ON m.winner_user_id = uw.id
LEFT JOIN public.users AS um ON m.merchant_user_id = um.id;
SQL

echo "View 'match_details' created successfully. Exporting data..."

psql "$DATABASE_URL" -c "SELECT * FROM public.match_details ORDER BY id DESC;" > "$OUTPUT_FILE"

echo "Export completed: $OUTPUT_FILE"
