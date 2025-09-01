import psycopg2, os

def main():
    try:
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST"),
            dbname=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASS"),
            port=os.getenv("DB_PORT"),
            sslmode="require"  # Render requires SSL
        )
        cur = conn.cursor()

        print("\n=== Users ===")
        cur.execute("SELECT id, phone, email, name, created_at FROM users LIMIT 10;")
        for row in cur.fetchall():
            print(row)

        print("\n=== OTPs (latest) ===")
        cur.execute("SELECT phone, code, used, expires_at FROM otps ORDER BY id DESC LIMIT 5;")
        for row in cur.fetchall():
            print(row)

        print("\n=== Wallet Transactions (latest) ===")
        cur.execute("SELECT id, user_id, amount, type, status, created_at FROM wallet_tx ORDER BY id DESC LIMIT 5;")
        for row in cur.fetchall():
            print(row)

        cur.close()
        conn.close()
    except Exception as e:
        print("❌ DB Error:", e)

if __name__ == "__main__":
    main()
