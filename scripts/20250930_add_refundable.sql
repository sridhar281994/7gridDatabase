-- Add abandoned state to match status enum
ALTER TYPE matchstatus ADD VALUE IF NOT EXISTS 'abandoned';
