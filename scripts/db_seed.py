import os
from sqlalchemy import create_engine, text

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise SystemExit("❌ DATABASE_URL not set")

engine = create_engine(DATABASE_URL, echo=True, future=True)

print(">>> Running DB seed for stakes...")

with engine.begin() as conn:
    # Ensure all tables exist
    conn.execute(text("""
    CREATE TABLE IF NOT EXISTS stakes (
        id SERIAL PRIMARY KEY,
        stake_amount INTEGER UNIQUE NOT NULL,
        entry_fee INTEGER NOT NULL,
        winner_payout INTEGER NOT NULL,
        label VARCHAR(50) NOT NULL
    );
    """))

    # --------------- 2-player stakes ----------------
    conn.execute(text("""
    INSERT INTO stakes (stake_amount, entry_fee, winner_payout, label)
    VALUES 
        (4, 2, 3, '₹4 (2-Player)'),
        (8, 4, 6, '₹8 (2-Player)'),
        (12, 6, 9, '₹12 (2-Player)')
    ON CONFLICT (stake_amount) DO NOTHING;
    """))

    # --------------- 3-player stakes ----------------
    conn.execute(text("""
    INSERT INTO stakes (stake_amount, entry_fee, winner_payout, label)
    VALUES 
        (104, 2, 4, '₹4 (3-Player)'),
        (108, 4, 8, '₹8 (3-Player)'),
        (112, 6, 12, '₹12 (3-Player)')
    ON CONFLICT (stake_amount) DO NOTHING;
    """))

print("✅ Stakes seeded successfully.")
