CREATE TABLE match_results (
    id SERIAL PRIMARY KEY,

    match_id INT NOT NULL REFERENCES game_matches(id) ON DELETE CASCADE,

    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    is_winner BOOLEAN NOT NULL DEFAULT FALSE,

    amount_change INT NOT NULL DEFAULT 0,
    -- negative for losers, positive for winner  

    before_balance INT NOT NULL DEFAULT 0,
    after_balance INT NOT NULL DEFAULT 0,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
