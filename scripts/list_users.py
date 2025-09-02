import os
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime, timedelta
DATABASE_URL = os.getenv("DATABASE_URL")
def main():
    if not DATABASE_URL:
        print(":x: DB Error: DATABASE_URL is not set in environment")
        return
    try:
        conn = psycopg2.connect(DATABASE_URL, sslmode="require")
        cur = conn.cursor(cursor_factory=RealDictCursor)
        # --- 1. Delete invalid WAITING matches (p1_user_id is NULL) ---
        cur.execute("SELECT id FROM game_matches WHERE status='WAITING' AND p1_user_id IS NULL;")
        bad_matches = cur.fetchall()
        if bad_matches:
            print(f":warning: Found {len(bad_matches)} invalid WAITING matches (p1_user_id=NULL). Deleting...")
            cur.execute("DELETE FROM game_matches WHERE status='WAITING' AND p1_user_id IS NULL;")
            conn.commit()
        else:
            print(":white_check_mark: No invalid WAITING matches.")
        # --- 2. Delete stale ACTIVE matches (>30 mins old) ---
        cutoff = datetime.utcnow() - timedelta(minutes=30)
        cur.execute("SELECT id FROM game_matches WHERE status='ACTIVE' AND created_at < %s;", (cutoff,))
        stale_matches = cur.fetchall()
        if stale_matches:
            print(f"⚠️ Found {len(stale_matches)} stale ACTIVE matches (>30 mins). Deleting...")
            cur.execute("DELETE FROM game_matches WHERE status='ACTIVE' AND created_at < %s;", (cutoff,))
            conn.commit()
        else:
            print(":white_check_mark: No stale ACTIVE matches.")
        # --- 3. Show all remaining matches with player names ---
        print("\n=== MATCHES ===")
        cur.execute("""
            SELECT m.id, m.stake_amount, m.status, m.p1_user_id, m.p2_user_id, m.created_at,
                   u1.name AS p1_name, u1.email AS p1_email,
                   u2.name AS p2_name, u2.email AS p2_email
            FROM game_matches m
            LEFT JOIN users u1 ON m.p1_user_id = u1.id
            LEFT JOIN users u2 ON m.p2_user_id = u2.id
            ORDER BY m.id DESC;
        """)
        matches = cur.fetchall()
        if not matches:
            print("No matches found.")
        else:
            for row in matches:
                p1_display = row["p1_name"] or row["p1_email"] or str(row["p1_user_id"])
                p2_display = row["p2_name"] or row["p2_email"] or str(row["p2_user_id"])
                print(f"ID={row['id']}, Stake={row['stake_amount']}, Status={row['status']}, "
                      f"P1={p1_display}, P2={p2_display}, Created={row['created_at']}")
        # --- 4. Show total ---
        cur.execute("SELECT COUNT(*) FROM game_matches;")
        total = cur.fetchone()["count"]
        print(f"\n:bar_chart: Total remaining matches: {total}")
        cur.close()
        conn.close()
    except Exception as e:
        print(f":x: DB Error: {e}")
if __name__ == "__main__":
    main()





