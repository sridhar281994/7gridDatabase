-- Add refundable column to game_matches table
ALTER TABLE game_matches
ADD COLUMN IF NOT EXISTS refundable boolean NOT NULL DEFAULT true;

-- Optional backfill: lock existing ACTIVE/FINISHED matches
UPDATE game_matches
SET refundable = false
WHERE status IN ('ACTIVE', 'FINISHED');
