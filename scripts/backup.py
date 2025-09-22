import os
import subprocess
from datetime import datetime

# --- ENV Variables ---
DB_URL = os.getenv("DATABASE_URL") # e.g. postgresql://user:pass@host:5432/dbname
BACKUP_DIR = "backups"
REPO_DIR = os.getenv("GITHUB_WORKSPACE", ".") # GitHub runner sets this

# --- Prepare paths ---
os.makedirs(BACKUP_DIR, exist_ok=True)
timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
backup_file = os.path.join(BACKUP_DIR, f"db_backup_{timestamp}.sql")

# --- Run pg_dump ---
print(f"[INFO] Dumping DB to {backup_file}")
subprocess.run(["pg_dump", DB_URL, "-f", backup_file], check=True)

# --- Git commit & push ---
subprocess.run(["git", "config", "user.name", "github-actions"], check=True)
subprocess.run(["git", "config", "user.email", "actions@github.com"], check=True)
subprocess.run(["git", "add", backup_file], check=True)
subprocess.run(["git", "commit", "-m", f"DB backup {timestamp}"], check=True)
subprocess.run(["git", "push"], check=True)

print("[INFO] Backup completed and pushed to GitHub 🚀")
