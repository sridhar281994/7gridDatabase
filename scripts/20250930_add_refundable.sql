-- Add refundable column if it does not exist
ALTER TABLE matches
ADD COLUMN IF NOT EXISTS refundable BOOLEAN NOT NULL DEFAULT true;
-- Backfill existing rows
UPDATE matches
SET refundable = true
WHERE refundable IS NULL;
