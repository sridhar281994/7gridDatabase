import os
from sqlalchemy import create_engine, text

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("❌ DATABASE_URL not set in environment")

engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    print(">>> Seeding stake data...")

    # Clear existing stakes
    conn.execute(text("DELETE FROM stakes"))

    # ✅ Insert 4 standard stages (Free Play + Paid)
    conn.execute(text("""
        INSERT INTO stakes (stake_amount, entry_fee, winner_payout, label)
        VALUES
            (0, 0, 0, 'Free Play'),
            (4, 2, 3, '₹4 Stage'),
            (8, 4, 6, '₹8 Stage'),
            (12, 6, 9, '₹12 Stage');
    """))
    conn.commit()

    # Confirm seeded
    rows = conn.execute(text("SELECT stake_amount, label FROM stakes ORDER BY stake_amount ASC")).fetchall()
    print("✅ Seeded stakes:")
    for r in rows:
        print(f"   - {r.label} (stake {r.stake_amount})")

print("✅ Done! Database now has Free Play and paid stages.")
