import os
import psycopg2
from psycopg2.extras import RealDictCursor
DB_URL = os.getenv("DATABASE_URL")
def cleanup_matches():
    try:
        conn = psycopg2.connect(DB_URL, sslmode="require")
        cur = conn.cursor(cursor_factory=RealDictCursor)
        # --- Cleanup invalid WAITING matches ---
        cur.execute("SELECT COUNT(*) FROM game_matches WHERE status='WAITING' AND p1_user_id IS NULL;")
        invalid_waiting = cur.fetchone()["count"]
        if invalid_waiting > 0:
            print(f":warning: Found {invalid_waiting} invalid WAITING matches (p1_user_id=NULL). Deleting...")
            cur.execute("DELETE FROM game_matches WHERE status='WAITING' AND p1_user_id IS NULL;")
            conn.commit()
        else:
            print(":white_check_mark: No invalid WAITING matches found.")
        # --- Cleanup stale ACTIVE matches older than 30 minutes ---
        cur.execute("""
            SELECT COUNT(*)
            FROM game_matches
            WHERE status='ACTIVE'
              AND created_at < NOW() - INTERVAL '30 minutes';
        """)
        stale_active = cur.fetchone()["count"]
        if stale_active > 0:
            print(f":warning: Found {stale_active} stale ACTIVE matches (>30 mins old). Deleting...")
            cur.execute("""
                DELETE FROM game_matches
                WHERE status='ACTIVE'
                  AND created_at < NOW() - INTERVAL '30 minutes';
            """)
            conn.commit()
        else:
            print(":white_check_mark: No stale ACTIVE matches found.")
        # --- Final counts for confirmation ---
        cur.execute("SELECT COUNT(*) FROM game_matches;")
        total = cur.fetchone()["count"]
        print(f":bar_chart: Total remaining matches: {total}")
        cur.close()
        conn.close()
    except Exception as e:
        print(f":x: DB Error: {e}")
if __name__ == "__main__":
    cleanup_matches()
