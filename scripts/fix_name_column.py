"""
scripts/fix_name_column.py
-------------------------------------------------
Patch script for ensuring the 'name' column exists
in the users table, and display all table info.
Also backfills name values if they are missing.
"""

from sqlalchemy import create_engine, inspect, text
import os

# --- Database URL ---
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise SystemExit("❌ DATABASE_URL environment variable not found.")

engine = create_engine(DATABASE_URL, echo=False, future=True)


def ensure_name_column():
    """Add 'name' column to users table if missing."""
    with engine.connect() as conn:
        insp = inspect(conn)
        cols = [c["name"] for c in insp.get_columns("users")]

        if "name" not in cols:
            print("🟡 'name' column missing — adding now...")
            conn.execute(text("ALTER TABLE users ADD COLUMN name VARCHAR(100);"))
            conn.commit()
            print("✅ Added 'name' column successfully.")
        else:
            print("✅ 'name' column already exists.")


def backfill_missing_names():
    """Fill NULL names from email prefix if needed."""
    with engine.connect() as conn:
        result = conn.execute(text("SELECT id, email, name FROM users;")).mappings().all()
        updates = 0
        for row in result:
            if not row["name"] or row["name"].strip() == "":
                derived = row["email"].split("@", 1)[0] if row["email"] else "Player"
                conn.execute(
                    text("UPDATE users SET name = :name WHERE id = :id;"),
                    {"name": derived, "id": row["id"]},
                )
                updates += 1
        if updates:
            conn.commit()
            print(f"✅ Backfilled {updates} user(s) with derived names.")
        else:
            print("✅ All users already have valid names.")


def print_all_table_info():
    """Print all tables and their columns."""
    with engine.connect() as conn:
        insp = inspect(conn)
        print("\n📋 Database Tables Overview:")
        for table_name in insp.get_table_names():
            print(f"\nTable: {table_name}")
            for col in insp.get_columns(table_name):
                print(f"  - {col['name']} ({col['type']})")


if __name__ == "__main__":
    print(">>> Running database integrity patch...")
    ensure_name_column()
    backfill_missing_names()
    print_all_table_info()
    print("\n✅ Database check complete.")
