#!/bin/bash
set -e

echo "=== Starting DB rollback ==="

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set"
  exit 1
fi

psql "$DATABASE_URL" <<'SQL'

-- 1) Remove is_agent column from users
ALTER TABLE users DROP COLUMN IF EXISTS is_agent;

-- 2) Remove merchant_user_id column from matches
ALTER TABLE matches DROP COLUMN IF EXISTS merchant_user_id;

-- 3) Remove refundable column from matches
ALTER TABLE matches DROP COLUMN IF EXISTS refundable;

-- 4) Remove forfeit_ids column from matches
ALTER TABLE matches DROP COLUMN IF EXISTS forfeit_ids;

-- 5) (Optional) Reset any agent users created manually
DELETE FROM users WHERE id BETWEEN 10001 AND 10020;

SQL

echo "=== Rollback complete ==="
