-- ============================================
-- 1. Create inspection table (safe)
-- ============================================
CREATE TABLE IF NOT EXISTS match_inspection (
    id SERIAL PRIMARY KEY,
    match_id INT,
    stake_amount INT,
    num_players INT,
    status TEXT,
    created_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    winner_user_id INT,
    player1 TEXT,
    player2 TEXT,
    player3 TEXT,
    winner_name TEXT,
    inspected_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 2. Insert latest inspection snapshot
-- ============================================
INSERT INTO match_inspection (
    match_id,
    stake_amount,
    num_players,
    status,
    created_at,
    finished_at,
    winner_user_id,
    player1,
    player2,
    player3,
    winner_name
)
SELECT
    m.id,
    m.stake_amount,
    m.num_players,
    m.status,
    m.created_at,
    m.finished_at,
    m.winner_user_id,
    COALESCE(u1.name, CONCAT('User-', m.p1_user_id)) AS player1,
    COALESCE(u2.name, CONCAT('User-', m.p2_user_id)) AS player2,
    COALESCE(u3.name, CONCAT('User-', m.p3_user_id)) AS player3,
    COALESCE(uw.name, CONCAT('User-', m.winner_user_id)) AS winner_name
FROM matches m
LEFT JOIN users u1 ON m.p1_user_id = u1.id
LEFT JOIN users u2 ON m.p2_user_id = u2.id
LEFT JOIN users u3 ON m.p3_user_id = u3.id
LEFT JOIN users uw ON m.winner_user_id = uw.id;

-- ============================================
-- 3. Export CSV into GitHub Actions workspace
-- ============================================
\copy (
    SELECT
        match_id,
        stake_amount,
        num_players,
        status,
        created_at,
        finished_at,
        winner_user_id,
        player1,
        player2,
        player3,
        winner_name,
        inspected_at
    FROM match_inspection
    ORDER BY id DESC
) TO 'backup/db_inspect/match_inspect.csv' CSV HEADER;
