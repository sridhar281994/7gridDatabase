import os
from sqlalchemy import create_engine, text

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise SystemExit("❌ DATABASE_URL not set")

engine = create_engine(DATABASE_URL, echo=True, future=True)

print(">>> Seeding base stages ₹4 / ₹8 / ₹12...")

with engine.begin() as conn:
    # Ensure stakes table exists
    conn.execute(text("""
    CREATE TABLE IF NOT EXISTS stakes (
        id SERIAL PRIMARY KEY,
        stake_amount INTEGER UNIQUE NOT NULL,
        entry_fee INTEGER NOT NULL,
        winner_payout INTEGER NOT NULL,
        label VARCHAR(50) NOT NULL
    );
    """))

    # 🧩 Base stake rules (used for both 2P and 3P)
    conn.execute(text("""
    INSERT INTO stakes (stake_amount, entry_fee, winner_payout, label)
    VALUES
        (4, 2, 3, '₹4 Stage'),
        (8, 4, 6, '₹8 Stage'),
        (12, 6, 9, '₹12 Stage')
    ON CONFLICT (stake_amount) DO NOTHING;
    """))

print("✅ Base stages seeded successfully!")
