-- Add abandoned state to matchstatus enum
ALTER TYPE matchstatus ADD VALUE IF NOT EXISTS 'abandoned';
