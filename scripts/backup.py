import os
import subprocess
import datetime
from urllib.parse import urlparse
db_url = os.getenv("DB_URL")
if not db_url:
    raise ValueError("DB_URL environment variable not set")
timestamp = datetime.datetime.now(datetime.UTC).strftime("%Y%m%d_%H%M%S")
backup_dir = "backups"
os.makedirs(backup_dir, exist_ok=True)
backup_file = os.path.join(backup_dir, f"db_backup_{timestamp}.sql")
print(f"[INFO] Dumping DB to {backup_file}")
# Parse DB URL for pg_dump
parsed = urlparse(db_url)
host = parsed.hostname
port = str(parsed.port or 5432)
user = parsed.username
password = parsed.password
dbname = parsed.path.lstrip("/")
# Pass password via environment so pg_dump won't prompt
env = os.environ.copy()
env["PGPASSWORD"] = password
cmd = [
    "pg_dump",
    "--no-owner",
    f"--host={host}",
    f"--port={port}",
    f"--username={user}",
    f"--dbname={dbname}",
    "-f", backup_file,
]
subprocess.run(cmd, check=True, env=env)
print("[INFO] Backup complete")





