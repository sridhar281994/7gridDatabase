-- Create match_results table to track winner/loser wallet changes
CREATE TABLE IF NOT EXISTS match_results (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    is_winner BOOLEAN NOT NULL,
    amount_change NUMERIC(12,2) NOT NULL,
    before_balance NUMERIC(12,2) NOT NULL,
    after_balance NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT fk_match
        FOREIGN KEY (match_id)
        REFERENCES game_matches(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- Optional index for faster inspection
CREATE INDEX IF NOT EXISTS idx_match_results_match_id
    ON match_results(match_id);

CREATE INDEX IF NOT EXISTS idx_match_results_user_id
    ON match_results(user_id);
