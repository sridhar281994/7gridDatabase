-- ========================================
-- 7GRID GameMatch Enhancement Migration
-- Adds fields for dynamic player tracking
-- ========================================

BEGIN;

-- 1. Create type if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'matchstatus') THEN
        CREATE TYPE matchstatus AS ENUM ('WAITING', 'ACTIVE', 'FINISHED');
    END IF;
END
$$;

-- 2. Ensure users table exists
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name TEXT,
    phone TEXT,
    wallet_balance NUMERIC DEFAULT 0
);

-- 3. Ensure game_matches table exists
CREATE TABLE IF NOT EXISTS game_matches (
    id SERIAL PRIMARY KEY,
    p1_user_id INT,
    p2_user_id INT,
    p3_user_id INT,
    stake_amount INT DEFAULT 0,
    num_players INT DEFAULT 2,
    current_turn INT DEFAULT 0,
    last_roll INT,
    status matchstatus DEFAULT 'WAITING',
    winner_user_id INT,
    created_at TIMESTAMPTZ DEFAULT now(),
    finished_at TIMESTAMPTZ,
    forfeit_ids INT[],
    active_player_count INT DEFAULT 0
);

-- 4. Add missing columns safely
ALTER TABLE game_matches ADD COLUMN IF NOT EXISTS forfeit_ids INT[];
ALTER TABLE game_matches ADD COLUMN IF NOT EXISTS active_player_count INT DEFAULT 0;

-- 5. Add trigger to auto-update modified time
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_game_matches_modtime') THEN
        CREATE OR REPLACE FUNCTION update_modtime_column()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.finished_at = NOW();
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER update_game_matches_modtime
        BEFORE UPDATE ON game_matches
        FOR EACH ROW
        EXECUTE FUNCTION update_modtime_column();
    END IF;
END
$$;

COMMIT;

SELECT '✅ Migration executed successfully' AS status;
