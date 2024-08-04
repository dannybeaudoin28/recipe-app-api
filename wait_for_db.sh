#!/usr/bin/env bash
set -e

host="postgres-container"
shift
cmd="$@"

until nc -z "$host" 5432; do
  echo "Waiting for $host to be available..."
  sleep 1
done

exec $cmd