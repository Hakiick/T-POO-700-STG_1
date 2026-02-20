#!/bin/bash
set -e

echo "=== TimeManager Container Starting ==="
echo "Environment: ${MIX_ENV:-prod}"

# Validate required environment variables
: "${DATABASE_URL:?ERROR: DATABASE_URL environment variable is required}"
: "${SECRET_KEY_BASE:?ERROR: SECRET_KEY_BASE environment variable is required}"

# Run Ecto migrations before starting the server
echo "Running database migrations..."
/app/backend/bin/time_manager eval "TimeManager.Release.migrate"
echo "Migrations complete."

# Start Phoenix in background
# PHX_SERVER=true tells runtime.exs to enable the HTTP server
echo "Starting Phoenix server on port 4000..."
PHX_SERVER=true /app/backend/bin/time_manager start &
PHOENIX_PID=$!

# Wait for Phoenix to be ready (up to 60 seconds)
echo "Waiting for Phoenix to be ready..."
READY=0
for i in $(seq 1 60); do
  if curl -sf http://localhost:4000/api/health > /dev/null 2>&1; then
    READY=1
    echo "Phoenix is ready after ${i}s."
    break
  fi
  sleep 1
done

if [ "$READY" -eq 0 ]; then
  echo "ERROR: Phoenix did not start within 60 seconds."
  kill "$PHOENIX_PID" 2>/dev/null || true
  exit 1
fi

# Start nginx in foreground so the container stays alive
# If nginx exits (e.g. on SIGTERM), the container stops
echo "Starting nginx on port 80..."
exec nginx -g "daemon off;"
