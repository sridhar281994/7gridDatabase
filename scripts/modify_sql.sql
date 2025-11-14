-- List all public tables
\echo 'Fetching table list...'
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public';

-- Dump every table fully
\echo 'Starting table exports...'

-- Loop not supported in plain SQL, so GitHub runs per-table manually
-- But we export matches + users + wallet + stakes

\echo 'Exporting matches...'
\copy (SELECT * FROM matches ORDER BY id) TO 'backup/db_inspect/matches.csv' CSV HEADER;

\echo 'Exporting users...'
\copy (SELECT * FROM users ORDER BY id) TO 'backup/db_inspect/users.csv' CSV HEADER;

\echo 'Exporting wallet_transactions...'
\copy (SELECT * FROM wallet_transactions ORDER BY id) TO 'backup/db_inspect/wallet_transactions.csv' CSV HEADER;

\echo 'Exporting stakes...'
\copy (SELECT * FROM stakes ORDER BY id) TO 'backup/db_inspect/stakes.csv' CSV HEADER;

\echo 'Exporting otps...'
\copy (SELECT * FROM otps ORDER BY id) TO 'backup/db_inspect/otps.csv' CSV HEADER;

\echo 'Completed table exports.'
