\echo 'Running migration...'

-- =============================
-- ENUMS
-- =============================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'matchstatus') THEN
        CREATE TYPE matchstatus AS ENUM ('waiting', 'active', 'finished', 'abandoned');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'txtype') THEN
        CREATE TYPE txtype AS ENUM ('recharge', 'withdraw', 'entry', 'win', 'fee');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'txstatus') THEN
        CREATE TYPE txstatus AS ENUM ('pending', 'success', 'failed');
    END IF;
END$$;

-- =============================
-- USERS TABLE
-- =============================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    phone VARCHAR UNIQUE NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    password_hash VARCHAR NOT NULL,
    name VARCHAR,
    upi_id VARCHAR,
    description VARCHAR(50),
    wallet_balance NUMERIC(10,2) DEFAULT 0,
    profile_image VARCHAR DEFAULT 'assets/default.png',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- =============================
-- OTPS TABLE
-- =============================
CREATE TABLE IF NOT EXISTS otps (
    id SERIAL PRIMARY KEY,
    phone VARCHAR NOT NULL,
    code VARCHAR NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================
-- MATCHES TABLE
-- =============================
CREATE TABLE IF NOT EXISTS matches (
    id SERIAL PRIMARY KEY,
    stake_amount INTEGER NOT NULL,
    p1_user_id INTEGER REFERENCES users(id),
    p2_user_id INTEGER REFERENCES users(id),
    p3_user_id INTEGER REFERENCES users(id),
    winner_user_id INTEGER REFERENCES users(id),
    merchant_user_id INTEGER REFERENCES users(id),
    status matchstatus DEFAULT 'waiting' NOT NULL,
    system_fee NUMERIC(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    finished_at TIMESTAMPTZ,
    last_roll INTEGER,
    current_turn INTEGER,
    num_players INTEGER DEFAULT 2 NOT NULL,
    refundable BOOLEAN DEFAULT TRUE NOT NULL,
    forfeit_ids INTEGER[] DEFAULT '{}'
);

-- =============================
-- WALLET TRANSACTIONS
-- =============================
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    tx_type txtype NOT NULL,
    status txstatus DEFAULT 'pending' NOT NULL,
    provider_ref VARCHAR,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    transaction_id VARCHAR UNIQUE
);

-- =============================
-- STAKES TABLE
-- =============================
CREATE TABLE IF NOT EXISTS stakes (
    id SERIAL PRIMARY KEY,
    stake_amount INTEGER UNIQUE NOT NULL,
    entry_fee INTEGER NOT NULL,
    winner_payout INTEGER NOT NULL,
    label VARCHAR(50) NOT NULL
);

-- =============================
-- ADD MISSING COLUMNS (safe re-run)
-- =============================
ALTER TABLE matches ADD COLUMN IF NOT EXISTS forfeit_ids INTEGER[];

-- =============================
-- TRIGGER: update updated_at on users
-- =============================
DROP TRIGGER IF EXISTS update_users_modtime ON users;
CREATE OR REPLACE FUNCTION update_users_modtime() RETURNS trigger AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_modtime
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_users_modtime();

\echo '✅ Migration complete'
