#!/bin/bash

# Run the id fetching script in this same folder ($0 => current script filepath)
container_id=$($(dirname "$0")/get_app_container_id.sh)

echo "Attaching to app container with id $container_id..."
echo "================="

docker attach $container_id
