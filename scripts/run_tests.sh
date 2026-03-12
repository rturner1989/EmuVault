#!/bin/bash


# Get the app container ID
container_id=$("$(dirname "$0")/get_app_container_id.sh")

echo "Running RSpec in app container with id $container_id..."
echo "================="

docker exec -e RAILS_ENV=test -it $container_id bundle exec rspec "$@"
