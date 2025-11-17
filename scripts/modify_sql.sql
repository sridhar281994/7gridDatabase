#!/bin/bash
set -e

echo "Starting PostgreSQL inspection and modification..."

# Define the path for the SQL script
SQL_SCRIPT_PATH="scripts/modify_sql.sql"

# Run the SQL script using psql
psql "$DATABASE_URL" -f "$SQL_SCRIPT_PATH"

echo "Database inspection and modification completed successfully."
