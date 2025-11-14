-- Fix lowercase match status values by converting them to uppercase
-- Safe to run multiple times (idempotent)

UPDATE matches SET status = 'WAITING' 
WHERE status = 'waiting';

UPDATE matches SET status = 'ACTIVE' 
WHERE status = 'active';

UPDATE matches SET status = 'FINISHED' 
WHERE status = 'finished';

UPDATE matches SET status = 'ABANDONED' 
WHERE status = 'abandoned';

-- Optional: confirm updates
SELECT id, status FROM matches ORDER BY id DESC LIMIT 20;
