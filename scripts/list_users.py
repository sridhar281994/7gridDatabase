import os
import psycopg2
from psycopg2.extras import RealDictCursor
# Render Postgres connection from env (same as before)
DB_URL = os.getenv("DATABASE_URL")
def cleanup_waiting_matches():
    try:
        conn = psycopg2.connect(DB_URL, sslmode="require")
        cur = conn.cursor(cursor_factory=RealDictCursor)
        # Count before cleanup
        cur.execute("SELECT COUNT(*) FROM game_matches WHERE status='waiting' AND p1_user_id IS NULL;")
        before_count = cur.fetchone()["count"]
        if before_count == 0:
            print(":white_check_mark: No invalid WAITING matches found.")
            cur.close()
            conn.close()
            return
        print(f":warning: Found {before_count} invalid WAITING matches (p1_user_id=NULL). Deleting...")
        # Delete them
        cur.execute("DELETE FROM game_matches WHERE status='waiting' AND p1_user_id IS NULL;")
        conn.commit()
        # Count after cleanup
        cur.execute("SELECT COUNT(*) FROM game_matches WHERE status='waiting' AND p1_user_id IS NULL;")
        after_count = cur.fetchone()["count"]
        print(f":white_check_mark: Cleanup complete. Remaining invalid matches: {after_count}")
        cur.close()
        conn.close()
    except Exception as e:
        print(f":x: DB Error: {e}")
if __name__ == "__main__":
    cleanup_waiting_matches()





