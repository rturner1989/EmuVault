#!/bin/bash

# Run the id fetching script in this same folder ($0 => current script filepath)
container_id=$($(dirname "$0")/get_app_container_id.sh)

echo "Running rails console on app container with id $container_id..."
echo "================="

docker exec -it $container_id rails c
