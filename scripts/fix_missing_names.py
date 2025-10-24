"""
scripts/fix_missing_names.py
----------------------------
One-time script to fill missing or blank 'name' fields in the users table
based on the email prefix (before '@').

Usage:
    python scripts/fix_missing_names.py
"""

from sqlalchemy import create_engine, text
import os

# ✅ Get database URL from environment variable
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise SystemExit("❌ DATABASE_URL not found. Please set it before running this script.")

engine = create_engine(DATABASE_URL)

with engine.begin() as conn:
    print("✅ Connected to database. Running update...")

    # Update only users who have no name or blank name
    result = conn.execute(
        text("""
        UPDATE users
        SET name = INITCAP(SPLIT_PART(email, '@', 1))
        WHERE (name IS NULL OR TRIM(name) = '')
        AND email IS NOT NULL;
        """)
    )

    print(f"✅ Updated {result.rowcount} user(s) with derived names.")

    # Optional: print out first few rows to verify
    rows = conn.execute(text("SELECT id, phone, email, name FROM users ORDER BY id LIMIT 10;")).fetchall()
    print("\n🧾 Sample users after update:")
    for r in rows:
        print(dict(r))

print("\n🎉 Done! All users without names now have readable defaults.")
