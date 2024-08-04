#!/bin/sh
# wait_for_db.sh

set -e

# Wait for PostgreSQL to become available
until pg_isready -h "$DB_HOST" -U "$DB_USER"; do
  echo "Waiting for database..."
  sleep 2
done

echo "Database is ready!"
