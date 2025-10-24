# scripts/db_migrate.py
import os
import sys
from sqlalchemy import create_engine

# --- Ensure we can import models/database from repo root ---
ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if ROOT_DIR not in sys.path:
    sys.path.append(ROOT_DIR)

from models import Base  # noqa
from database import Base as DBBase  # just in case

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise SystemExit("❌ DATABASE_URL not found in environment variables")

print(f"🗃️  Connecting to database: {DATABASE_URL}")
engine = create_engine(DATABASE_URL, echo=True, future=True)

print("🧱 Creating all tables from models...")
Base.metadata.create_all(bind=engine)
print("✅ Migration complete — all tables are up to date.")
