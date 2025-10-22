#!/usr/bin/env bash
set -e

echo "🔍 Checking and updating PostgreSQL schema..."

# Ensure required environment variables exist
if [[ -z "$DATABASE_URL" ]]; then
  echo "❌ DATABASE_URL not set."
  exit 1
fi

# Strip postgres:// prefix for psql compatibility
CONN_URL="${DATABASE_URL/postgres:\/\//postgresql:\/\/}"

SQL_COMMANDS=$(cat <<'SQL'
-- =============================
-- Ensure required schema updates
-- =============================

-- Add merchant_user_id column to matches
ALTER TABLE matches
ADD COLUMN IF NOT EXISTS merchant_user_id INTEGER REFERENCES users(id);

-- Add num_players column to matches
ALTER TABLE matches
ADD COLUMN IF NOT EXISTS num_players INTEGER NOT NULL DEFAULT 2;

-- Add refundable column to matches
ALTER TABLE matches
ADD COLUMN IF NOT EXISTS refundable BOOLEAN NOT NULL DEFAULT TRUE;

-- Add profile_image column to users
ALTER TABLE users
ADD COLUMN IF NOT EXISTS profile_image TEXT DEFAULT 'assets/default.png';

-- Ensure all new columns are visible
\d+ matches;
\d+ users;
SQL
)

# Run migrations
echo "⚙️  Running migrations..."
echo "$SQL_COMMANDS" | psql "$CONN_URL"

echo "✅ Migration complete!"
