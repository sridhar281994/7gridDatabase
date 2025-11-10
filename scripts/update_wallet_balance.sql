#!/bin/bash
set -e

echo "Updating wallet balances for selected users..."

psql "$DATABASE_URL" <<'SQL'
UPDATE users
SET wallet_balance = 500
WHERE email IN (
  'sri198528@gmail.com',
  'sri.christh@gmail.com',
  'sridhar.christh@gmail.com'
);
SQL

echo "✅ Wallet balances updated to ₹500 for specified users."
