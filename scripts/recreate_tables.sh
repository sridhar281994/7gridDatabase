#!/usr/bin/env bash
set -e

# --- Parse DB URL into components ---
echo "Parsing DATABASE_URL..."
DB_URL="$DATABASE_URL"
if [[ -z "$DB_URL" ]]; then
  echo "[ERROR] DATABASE_URL is missing!"
  exit 1
fi

# Extract connection parameters
PROTO="$(echo $DB_URL | sed -E 's#(.*)://.*#\1#')"
USER="$(echo $DB_URL | sed -E 's#.*://([^:]+):.*#\1#')"
PASS="$(echo $DB_URL | sed -E 's#.*://[^:]+:([^@]+)@.*#\1#')"
HOST="$(echo $DB_URL | sed -E 's#.*@([^:/]+).*#\1#')"
DBNAME="$(echo $DB_URL | sed -E 's#.*/([^/?]+).*#\1#')"

export PGPASSWORD=$PASS

echo "Recreating tables in $DBNAME on $HOST..."

psql -h "$HOST" -U "$USER" -d "$DBNAME" -v ON_ERROR_STOP=1 <<'SQL'

-- =========================
-- ENUM TYPES
-- =========================
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

-- =========================
-- USERS TABLE
-- =========================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    upi_id VARCHAR(100),
    description VARCHAR(255),
    wallet_balance NUMERIC(12,2) DEFAULT 0,
    profile_image VARCHAR DEFAULT 'assets/default.png',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- =========================
-- OTP TABLE
-- =========================
CREATE TABLE IF NOT EXISTS otps (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20) NOT NULL,
    code VARCHAR(10) NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================
-- MATCHES TABLE
-- =========================
CREATE TABLE IF NOT EXISTS matches (
    id SERIAL PRIMARY KEY,
    stake_amount INTEGER NOT NULL,
    p1_user_id INTEGER REFERENCES users(id),
    p2_user_id INTEGER REFERENCES users(id),
    p3_user_id INTEGER REFERENCES users(id),
    winner_user_id INTEGER REFERENCES users(id),
    status matchstatus NOT NULL DEFAULT 'waiting',
    system_fee NUMERIC(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    finished_at TIMESTAMPTZ,
    last_roll INTEGER,
    current_turn INTEGER,
    num_players INTEGER NOT NULL DEFAULT 2,
    refundable BOOLEAN NOT NULL DEFAULT TRUE,
    merchant_user_id INTEGER REFERENCES users(id)
);

-- =========================
-- WALLET TRANSACTIONS TABLE
-- =========================
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    amount NUMERIC(10,2) NOT NULL,
    tx_type txtype NOT NULL,
    status txstatus NOT NULL DEFAULT 'pending',
    provider_ref VARCHAR,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    transaction_id VARCHAR UNIQUE
);

-- =========================
-- STAKES TABLE
-- =========================
CREATE TABLE IF NOT EXISTS stakes (
    id SERIAL PRIMARY KEY,
    stake_amount INTEGER UNIQUE NOT NULL,
    entry_fee INTEGER NOT NULL,
    winner_payout INTEGER NOT NULL,
    label VARCHAR(50) NOT NULL
);

SQL

echo "✅ Database tables recreated successfully."
