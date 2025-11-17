-- -------------------------
-- SQL Script to Modify Database for ROBOTS Army Stage (2-player & 3-player)
-- -------------------------

-- Add new stage "ROBOTS Army" for 2-player if it doesn't already exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM stages WHERE label = 'ROBOTS Army' AND players = 2) THEN
        INSERT INTO stages (stake_amount, entry_fee, winner_payout, players, label)
        VALUES (0, 0, 0, 2, 'ROBOTS Army');
    END IF;
END $$;

-- Add new stage "ROBOTS Army" for 3-player if it doesn't already exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM stages WHERE label = 'ROBOTS Army' AND players = 3) THEN
        INSERT INTO stages (stake_amount, entry_fee, winner_payout, players, label)
        VALUES (0, 0, 0, 3, 'ROBOTS Army');
    END IF;
END $$;

-- You can add further queries for other inspections or modifications here
-- Example: Check the number of stages and print to file
SELECT * FROM stages;
