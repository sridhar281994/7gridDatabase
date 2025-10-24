import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import (
    Column, Integer, String, DateTime, Boolean, ForeignKey, Numeric, Enum, text as sa_text
)
from sqlalchemy.sql import func
import enum

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise SystemExit("❌ DATABASE_URL not set")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

# -----------------------
# Enums
# -----------------------
class MatchStatus(enum.Enum):
    WAITING = "waiting"
    ACTIVE = "active"
    FINISHED = "finished"
    ABANDONED = "abandoned"

class TxType(enum.Enum):
    RECHARGE = "recharge"
    WITHDRAW = "withdraw"
    ENTRY = "entry"
    WIN = "win"
    FEE = "fee"

class TxStatus(enum.Enum):
    PENDING = "pending"
    SUCCESS = "success"
    FAILED = "failed"

# -----------------------
# Models
# -----------------------
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String(20), unique=True, nullable=False)
    name = Column(String(100))
    email = Column(String(255), unique=True)
    password_hash = Column(String(255))
    upi_id = Column(String(100))
    description = Column(String(255))
    wallet_balance = Column(Numeric(12, 2), default=0)
    profile_image = Column(String, default="assets/default.png")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class GameMatch(Base):
    __tablename__ = "matches"
    id = Column(Integer, primary_key=True, index=True)
    stake_amount = Column(Integer, nullable=False)
    p1_user_id = Column(Integer, ForeignKey("users.id"))
    p2_user_id = Column(Integer, ForeignKey("users.id"))
    p3_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    winner_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    merchant_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    status = Column(Enum(MatchStatus), default=MatchStatus.WAITING, nullable=False)
    system_fee = Column(Numeric(10, 2), default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    finished_at = Column(DateTime(timezone=True))
    last_roll = Column(Integer)
    current_turn = Column(Integer)
    num_players = Column(Integer, nullable=False, default=2)
    refundable = Column(Boolean, nullable=False, server_default=sa_text("true"))

class WalletTransaction(Base):
    __tablename__ = "wallet_transactions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    amount = Column(Numeric(10, 2), nullable=False)
    tx_type = Column(Enum(TxType), nullable=False)
    status = Column(Enum(TxStatus), default=TxStatus.PENDING, nullable=False)
    provider_ref = Column(String)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    transaction_id = Column(String, unique=True)

class OTP(Base):
    __tablename__ = "otps"
    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String, nullable=False, index=True)
    code = Column(String, nullable=False)
    used = Column(Boolean, default=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

print("🔧 Creating tables if not exist...")
Base.metadata.create_all(bind=engine)
print("✅ Migration complete.")
