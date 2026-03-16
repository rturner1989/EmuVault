#!/bin/bash

echo "Stopping app and sidekiq to release DB connections..."
docker compose stop app sidekiq

echo "Resetting database..."
echo "================="
docker compose run --rm app sh -c "rails db:drop db:create db:migrate db:seed"

echo "Restarting services..."
docker compose start app sidekiq

echo "Done! You can now test the first-run setup wizard."
