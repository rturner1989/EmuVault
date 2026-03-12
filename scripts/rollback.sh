#!/bin/bash

container_id=$($(dirname "$0")/get_app_container_id.sh)

echo "ROLLBACK app container with id $container_id..."
echo "================="

docker compose run --rm app rails db:rollback

echo "Finished!"
