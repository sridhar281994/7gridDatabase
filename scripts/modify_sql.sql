-- fix enum values to lowercase
ALTER TYPE matchstatus RENAME TO matchstatus_old;

CREATE TYPE matchstatus AS ENUM (
    'waiting',
    'active',
    'finished',
    'abandoned'
);

ALTER TABLE matches
    ALTER COLUMN status TYPE matchstatus
    USING LOWER(status)::matchstatus;

DROP TYPE matchstatus_old;

-- normalize all existing rows
UPDATE matches SET status = LOWER(status)::matchstatus;
