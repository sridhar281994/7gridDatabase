UPDATE matches SET status = 'WAITING'   WHERE status = 'waiting';
UPDATE matches SET status = 'ACTIVE'    WHERE status = 'active';
UPDATE matches SET status = 'FINISHED'  WHERE status = 'finished';
UPDATE matches SET status = 'ABANDONED' WHERE status = 'abandoned';
