# Render PostgreSQL DB Check via GitHub Actions

This repo lets you securely connect to your Render-hosted PostgreSQL DB from GitHub Actions.

## Setup

1. Go to **GitHub → Repo → Settings → Secrets → Actions**.
2. Add the following secrets:
   - `DB_HOST` = `dpg-d1v8s9emcj7s73f6bemg-a.virginia-postgres.render.com`
   - `DB_NAME` = `spin_db`
   - `DB_USER` = `spin_db_user`
   - `DB_PASS` = (your DB password from Render)
   - `DB_PORT` = `5432`

3. Push this repo to GitHub.
4. Go to **Actions tab** → Run workflow → DB Check.

It will print users, OTPs, and wallet transactions directly in the Actions logs.
