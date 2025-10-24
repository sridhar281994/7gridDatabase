# scripts/db_migrate.py
import os
import sys
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError

# ✅ Add project root path
ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

print(f"[DEBUG] Using root path: {ROOT_DIR}")

try:
    from models import Base
    from models import User, OTP, GameMatch, WalletTransaction, Stake
except ModuleNotFoundError as e:
    print(f"❌ Import error: {e}")
    sys.exit(1)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("❌ DATABASE_URL not found in environment variables.")
    sys.exit(1)

print(f"🗄️ Connecting to {DATABASE_URL}")

engine = create_engine(DATABASE_URL, echo=True, future=True)

try:
    Base.metadata.create_all(bind=engine)
    print("✅ Migration complete. All tables are now synced.")
    print("📋 Tables created:")
    for t in Base.metadata.tables.keys():
        print(f" - {t}")
except SQLAlchemyError as e:
    print(f"❌ SQLAlchemy error: {e}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Unexpected error: {e}")
    sys.exit(1)
