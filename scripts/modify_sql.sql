-- -------------------------
-- SQL Script to Inspect and Modify Database for "ROBOTS Army" Stage
-- -------------------------

-- Check and add ROBOTS Army for 2-player mode
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM stages WHERE label = 'ROBOTS Army' AND players = 2) THEN
        INSERT INTO stages (stake_amount, entry_fee, winner_payout, players, label)
        VALUES (0, 0, 0, 2, 'ROBOTS Army');
    END IF;
END $$;

-- Check and add ROBOTS Army for 3-player mode
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM stages WHERE label = 'ROBOTS Army' AND players = 3) THEN
        INSERT INTO stages (stake_amount, entry_fee, winner_payout, players, label)
        VALUES (0, 0, 0, 3, 'ROBOTS Army');
    END IF;
END $$;

-- Example: Check all entries in the 'stages' table
SELECT id, stake_amount, entry_fee, winner_payout, players, label FROM stages;
