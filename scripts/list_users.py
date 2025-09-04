import os
from sqlalchemy import create_engine, text
# --- Database URL with sslmode=require for Render ---
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://spin_db_user:gha2FPMzzfwVFaPC88yzihY9MjBtkPgT"
    "@dpg-d1v8s9emcj7s73f6bemg-a.virginia-postgres.render.com/spin_db?sslmode=require"
)
def run_migration():
    print(":rocket: Starting migration: add updated_at column to users table")
    engine = create_engine(DATABASE_URL, echo=True, future=True)
    with engine.connect() as conn:
        try:
            conn.execute(text("""
                ALTER TABLE users
                ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();
            """))
            conn.commit()
            print(":white_check_mark: Migration successful: updated_at added (if not exists)")
        except Exception as e:
            print(f":x: Migration failed: {e}")
            raise
if __name__ == "__main__":
    run_migration()









