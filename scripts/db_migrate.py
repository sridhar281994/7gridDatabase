# db_migrate.py
import os
from sqlalchemy import create_engine
from models import Base

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise SystemExit("❌ DATABASE_URL not found in environment variables")

print(f"🗃️  Connecting to database: {DATABASE_URL}")
engine = create_engine(DATABASE_URL, echo=True, future=True)

print("🧱 Creating all tables from models...")
Base.metadata.create_all(bind=engine)
print("✅ Migration complete — all tables are up to date.")
