import os
import psycopg2
def main():
    conn = None
    try:
        conn = psycopg2.connect(
            host=os.environ["DB_HOST"],
            dbname=os.environ["DB_NAME"],
            user=os.environ["DB_USER"],
            password=os.environ["DB_PASSWORD"],
            port=os.environ.get("DB_PORT", 5432),
            sslmode="require"
        )
        cur = conn.cursor()
        # === USERS ===
        print("\n=== USERS ===")
        # Try to include token if it exists
        try:
            cur.execute("SELECT id, email, name, token FROM users ORDER BY id ASC;")
            for row in cur.fetchall():
                print(f"ID={row[0]}, Email={row[1]}, Name={row[2]}, Token={row[3]}")
        except Exception:
            # fallback if no token column
            conn.rollback()
            cur.execute("SELECT id, email, name FROM users ORDER BY id ASC;")
            for row in cur.fetchall():
                print(f"ID={row[0]}, Email={row[1]}, Name={row[2]}")
        # === MATCHES ===
        print("\n=== MATCHES ===")
        table_names = ["game_match", "game_matches"]
        found = False
        for tbl in table_names:
            try:
                cur.execute(
                    f"SELECT id, stake_amount, status, p1_user_id, p2_user_id "
                    f"FROM {tbl} ORDER BY id DESC LIMIT 20;"
                )
                rows = cur.fetchall()
                for row in rows:
                    print(f"ID={row[0]}, Stake={row[1]}, Status={row[2]}, P1={row[3]}, P2={row[4]}")
                found = True
                break
            except Exception as e:
                conn.rollback()
                print(f"Tried {tbl}: {e}")
        if not found:
            print("No match table found (tried game_match and game_matches).")
        cur.close()
    except Exception as e:
        print(f"DB Error: {e}")
    finally:
        if conn:
            conn.close()
if __name__ == "__main__":
    main()

