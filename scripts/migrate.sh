#!/bin/bash

container_id=$($(dirname "$0")/get_app_container_id.sh)

echo "MIGRATE app container with id $container_id..."
echo "================="

docker compose run --rm app sh -c "rails db:migrate && bundle exec annotaterb models"

echo "Finished!"
