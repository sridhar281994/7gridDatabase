import psycopg2
import os
def main():
    try:
        conn = psycopg2.connect(
            os.environ["DATABASE_URL"],
            sslmode="require"  # enforce SSL for Render
        )
        cur = conn.cursor()
        # === USERS ===
        print("\n=== USERS ===")
        try:
            cur.execute("SELECT id, email, name FROM users LIMIT 20;")
            for row in cur.fetchall():
                print(f"ID={row[0]}, Email={row[1]}, Name={row[2]}")
        except Exception as e:
            print(f"Could not fetch users: {e}")
        # === MATCHES ===
        print("\n=== MATCHES ===")
        try:
            cur.execute("SELECT id, stake_amount, status, p1_user_id, p2_user_id "
                        "FROM game_match ORDER BY id DESC LIMIT 20;")
            for row in cur.fetchall():
                print(f"ID={row[0]}, Stake={row[1]}, Status={row[2]}, P1={row[3]}, P2={row[4]}")
        except Exception as e:
            print(f"Could not fetch matches: {e}")
        cur.close()
        conn.close()
    except Exception as e:
        print(f":x: DB Error: {e}")
if __name__ == "__main__":
    main()
