from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import Base, User, OTP, GameMatch, WalletTransaction, Stake
import os

print("Starting database migration...")

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL not found in environment variables.")

# Create engine
engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine)

try:
    Base.metadata.create_all(bind=engine)
    print("✅ All tables created/updated successfully.")
except Exception as e:
    print(f"❌ Migration failed: {e}")
