DROP TABLE IF EXISTS stakes;

CREATE TABLE stakes (
    id SERIAL PRIMARY KEY,
    stake_amount INTEGER NOT NULL,       -- 0, 2, 4, 6
    entry_fee INTEGER NOT NULL,          -- same for 2P/3P
    winner_payout INTEGER NOT NULL,      -- different for 2P vs 3P
    players INTEGER NOT NULL,            -- 2 or 3
    label VARCHAR(50) NOT NULL
);

-- -------------------------
-- 2 PLAYER RULES
-- -------------------------
INSERT INTO stakes (stake_amount, entry_fee, winner_payout, players, label) VALUES
(0, 0, 0, 2, 'Free Play'),
(2, 2, 3, 2, 'Dual Rush'),
(4, 4, 6, 2, 'QUAD Crush'),
(6, 6, 9, 2, 'siXth Gear');

-- -------------------------
-- 3 PLAYER RULES
-- -------------------------
INSERT INTO stakes (stake_amount, entry_fee, winner_payout, players, label) VALUES
(0, 0, 0, 3, 'Free Play'),
(2, 2, 4, 3, 'Dual Rush'),
(4, 4, 8, 3, 'QUAD Crush'),
(6, 6, 12, 3, 'siXth Gear');
