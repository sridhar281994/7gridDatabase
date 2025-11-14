-- Create inspection table if not exists
CREATE TABLE IF NOT EXISTS match_inspection (
    id SERIAL PRIMARY KEY,
    match_id INT NOT NULL,
    stake INT,
    num_players INT,
    status TEXT,
    created_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    winner_user_id INT,
    p1 TEXT,
    p2 TEXT,
    p3 TEXT
);

-- Insert data
INSERT INTO match_inspection (match_id, stake, num_players, status,
                              created_at, finished_at, winner_user_id,
                              p1, p2, p3)
SELECT
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
LEFT JOIN users u1 ON m.p1_user_id = u1.id
LEFT JOIN users u2 ON m.p2_user_id = u2.id
LEFT JOIN users u3 ON m.p3_user_id = u3.id;

-- Export CSV
\copy (
    SELECT * FROM match_inspection ORDER BY match_id DESC
) TO 'backup/db_inspect/match_inspect.csv' CSV HEADER;
