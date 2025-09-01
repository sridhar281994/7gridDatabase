import os
import psycopg2
from urllib.parse import urlparse
def main():
    conn = None
    try:
        database_url = os.environ.get("DATABASE_URL")
        if not database_url:
            raise RuntimeError("DATABASE_URL not set in environment")
        result = urlparse(database_url)
        conn = psycopg2.connect(
            dbname=result.path[1:],
            user=result.username,
            password=result.password,
            host=result.hostname,
            port=result.port,
            sslmode="require",
        )
        cur = conn.cursor()
        print("\n=== USERS ===")
        try:
            cur.execute("SELECT id, email, name FROM users ORDER BY id ASC;")
            for row in cur.fetchall():
                print(f"ID={row[0]}, Email={row[1]}, Name={row[2]}")
        except Exception as e:
            print(f"Could not fetch users: {e}")
            conn.rollback()
        print("\n=== MATCHES ===")
        for tbl in ["game_match", "game_matches"]:
            try:
                cur.execute(
                    f"SELECT id, stake_amount, status, p1_user_id, p2_user_id "
                    f"FROM {tbl} ORDER BY id DESC LIMIT 20;"
                )
                rows = cur.fetchall()
                for row in rows:
                    print(f"ID={row[0]}, Stake={row[1]}, Status={row[2]}, P1={row[3]}, P2={row[4]}")
                break
            except Exception as e:
                print(f"Tried {tbl}: {e}")
                conn.rollback()
        cur.close()
    except Exception as e:
        print(f"DB Error: {e}")
    finally:
        if conn:
            conn.close()
if __name__ == "__main__":
    main()





