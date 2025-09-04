from sqlalchemy import create_engine, text
import os
# Get DATABASE_URL from environment variable
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError(":x: DATABASE_URL environment variable is missing!")
# Create DB engine
engine = create_engine(DATABASE_URL)
def list_users():
    query = text("""
        SELECT id, phone, email, wallet_balance, created_at, updated_at
        FROM users
        ORDER BY id ASC;
    """)
    with engine.connect() as conn:
        rows = conn.execute(query).fetchall()
    if not rows:
        print(":warning: No users found in database.")
        return
    # Print header
    headers = ["ID", "Phone", "Email", "Wallet", "Created At", "Updated At"]
    print("-" * 100)
    print("{:<5} {:<12} {:<25} {:<10} {:<20} {:<20}".format(*headers))
    print("-" * 100)
    # Print each row
    for row in rows:
        print("{:<5} {:<12} {:<25} {:<10} {:<20} {:<20}".format(
            row.id, row.phone or "-", row.email or "-",
            row.wallet_balance or 0,
            str(row.created_at) if row.created_at else "-",
            str(row.updated_at) if row.updated_at else "-"
        ))
    print("-" * 100)
if __name__ == "__main__":
    list_users()
