-- Daily DB Inspection Script
-- This script runs inside postgres:17 container using `psql -f`

-- Create a summary view if not exists
CREATE OR REPLACE VIEW match_details AS
SELECT
  m.id AS match_id,
  m.stake_amount,
  m.num_players,
  m.status,
  m.created_at,
  m.finished_at,
  m.winner_user_id,
  u1.name AS player1,
  u2.name AS player2,
  u3.name AS player3,
  w.name  AS winner
FROM matches m
LEFT JOIN users u1 ON u1.id = m.p1_user_id
LEFT JOIN users u2 ON u2.id = m.p2_user_id
LEFT JOIN users u3 ON u3.id = m.p3_user_id
LEFT JOIN users w  ON w.id  = m.winner_user_id;

-- Export inspection output to file
\copy (
    SELECT *
    FROM match_details
    ORDER BY match_id DESC
) TO 'backup/db_inspect/match_details.csv' CSV HEADER;

-- Export wallet transactions
\copy (
    SELECT *
    FROM wallet_transactions
    ORDER BY timestamp DESC
) TO 'backup/db_inspect/wallet_transactions.csv' CSV HEADER;

-- Export users balance snapshot
\copy (
    SELECT id, name, phone, wallet_balance
    FROM users
    ORDER BY id
) TO 'backup/db_inspect/users_balance.csv' CSV HEADER;
