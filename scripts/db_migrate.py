# scripts/db_migrate.py
import os
import sys
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError

# --- Locate backend folder ---
ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BACKEND_DIR = os.path.join(ROOT_DIR, "backend")
sys.path.append(BACKEND_DIR)

print(f"[DEBUG] Using backend path: {BACKEND_DIR}")

try:
    from models import Base
except Exception as e:
    print(f"❌ Failed to import models: {e}")
    sys.exit(1)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("❌ DATABASE_URL not found in environment.")
    sys.exit(1)

print("🗄️ Connecting to database...")
engine = create_engine(DATABASE_URL, echo=True, future=True)

try:
    print("⚠️ Dropping all existing tables (dev mode cleanup)...")
    Base.metadata.drop_all(bind=engine)
    print("✅ All tables dropped successfully.")

    print("🛠️ Creating tables...")
    Base.metadata.create_all(bind=engine)

    print("✅ All tables created successfully.")
    print("📋 Tables:")
    for t in Base.metadata.tables.keys():
        print(f" - {t}")

except SQLAlchemyError as e:
    print(f"❌ SQLAlchemy error: {e}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Unexpected error: {e}")
    sys.exit(1)
