# scripts/db_migrate.py
import os, sys
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError

# --- Auto locate project root (1 level above scripts/) ---
ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(ROOT_DIR)
print(f"[DEBUG] Added ROOT_DIR to path: {ROOT_DIR}")

try:
    from models import Base
    from models import User, OTP, GameMatch, WalletTransaction, Stake
except Exception as e:
    print(f"❌ Failed to import models: {e}")
    sys.exit(1)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("❌ DATABASE_URL environment variable not found.")
    sys.exit(1)

print(f"🗄️ Connecting to database...")
engine = create_engine(DATABASE_URL, echo=True, future=True)

try:
    Base.metadata.create_all(bind=engine)
    print("✅ All tables synced successfully.")
    print("📋 Tables:")
    for t in Base.metadata.tables.keys():
        print(f" - {t}")
except SQLAlchemyError as e:
    print(f"❌ SQLAlchemy error: {e}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Unexpected error: {e}")
    sys.exit(1)
