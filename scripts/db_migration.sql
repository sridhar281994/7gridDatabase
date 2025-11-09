-- =========================================
-- DATABASE MIGRATION SCRIPT
-- =========================================

CREATE TYPE match_status AS ENUM ('WAITING', 'ACTIVE', 'FINISHED');

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20) UNIQUE,
    name VARCHAR(100),
    upi_id VARCHAR(100),
    wallet_points INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS game_matches (
    id SERIAL PRIMARY KEY,
    p1_user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    p2_user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    p3_user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    current_turn INTEGER DEFAULT 0,
    last_roll INTEGER,
    status match_status DEFAULT 'WAITING',
    forfeit_ids INTEGER[] DEFAULT '{}',
    active_player_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Ensure consistency and add columns if missing
ALTER TABLE game_matches ADD COLUMN IF NOT EXISTS forfeit_ids INTEGER[] DEFAULT '{}';
ALTER TABLE game_matches ADD COLUMN IF NOT EXISTS active_player_count INTEGER DEFAULT 0;

-- Trigger for updated timestamp
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_game_matches_modtime ON game_matches;
CREATE TRIGGER update_game_matches_modtime
BEFORE UPDATE ON game_matches
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

SELECT '✅ Migration executed successfully' AS status;
