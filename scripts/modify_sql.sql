-- ==========================================
-- 1. Create table (safe if exists)
-- ==========================================
CREATE TABLE IF NOT EXISTS match_inspection (
    id SERIAL PRIMARY KEY,
    match_id INT,
    stake_amount INT,
    num_players INT,
    status TEXT,
    created_at TIMESTAMP,
    finished_at TIMESTAMP,
    winner_user_id INT,
    p1_name TEXT,
    p2_name TEXT,
    p3_name TEXT,
    winner_name TEXT,
    inspected_at TIMESTAMP DEFAULT NOW()
);

-- ==========================================
-- 2. Clear previous data
-- ==========================================
TRUNCATE match_inspection;

-- ==========================================
-- 3. Insert fresh match snapshot
-- ==========================================
INSERT INTO match_inspection (
    match_id,
    stake_amount,
    num_players,
    status,
    created_at,
    finished_at,
    winner_user_id,
    p1_name,
    p2_name,
    p3_name,
    winner_name
)
SELECT
    m.id,
    m.stake_amount,
    m.num_players,
    m.status::TEXT,
    m.created_at,
    m.finished_at,
    m.winner_user_id,
    COALESCE(u1.name, 'Unknown') AS p1_name,
    COALESCE(u2.name, 'Unknown') AS p2_name,
    COALESCE(u3.name, 'Unknown') AS p3_name,
    COALESCE(w.name, 'Unknown') AS winner_name
FROM matches m
LEFT JOIN users u1 ON m.p1_user_id = u1.id
LEFT JOIN users u2 ON m.p2_user_id = u2.id
LEFT JOIN users u3 ON m.p3_user_id = u3.id
LEFT JOIN users w  ON m.winner_user_id = w.id;

-- ==========================================
-- 4. Export CSV (correct \copy syntax)
-- ==========================================
\copy (
    SELECT
        match_id,
        stake_amount,
        num_players,
        status,
        created_at,
        finished_at,
        winner_user_id,
        p1_name,
        p2_name,
        p3_name,
        winner_name,
        inspected_at
    FROM match_inspection
) TO 'backup/db_inspect/match_inspect.csv' CSV HEADER;
