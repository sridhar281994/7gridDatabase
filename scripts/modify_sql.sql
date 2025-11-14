-- Create inspection table if not exists
CREATE TABLE IF NOT EXISTS match_inspection (
    run_at TIMESTAMP NOT NULL,
    match_id INTEGER,
    stake_amount INTEGER,
    num_players INTEGER,
    status TEXT,
    created_at TIMESTAMP,
    finished_at TIMESTAMP,
    winner_user_id INTEGER,
    p1 TEXT,
    p2 TEXT,
    p3 TEXT
);

-- Insert inspection snapshot
INSERT INTO match_inspection (run_at, match_id, stake_amount, num_players, status,
                              created_at, finished_at, winner_user_id,
                              p1, p2, p3)
SELECT 
    NOW() AS run_at,
    m.id,
    m.stake_amount,
    m.num_players,
    m.status,
    m.created_at,
    m.finished_at,
    m.winner_user_id,
    u1.name AS p1,
    u2.name AS p2,
    u3.name AS p3
FROM matches m
LEFT JOIN users u1 ON u1.id = m.p1_user_id
LEFT JOIN users u2 ON u2.id = m.p2_user_id
LEFT JOIN users u3 ON u3.id = m.p3_user_id;

-- Export snapshot to CSV
\copy (
    SELECT *
    FROM match_inspection
    ORDER BY run_at DESC
) TO 'backup/db_inspect/match_inspect.csv' CSV HEADER;
