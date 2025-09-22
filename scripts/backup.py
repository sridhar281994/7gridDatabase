import os, subprocess, datetime

db_url = os.environ["DB_URL"]
os.makedirs("backups", exist_ok=True)

timestamp = datetime.datetime.utcnow().strftime("%Y%m%d_%H%M%S")
backup_file = f"backups/db_backup_{timestamp}.sql"

print(f"[INFO] Dumping DB to {backup_file}")
subprocess.run(["pg_dump", db_url, "-f", backup_file], check=True)
print("[INFO] Backup complete")
