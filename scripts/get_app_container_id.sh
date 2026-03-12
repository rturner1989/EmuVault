#!/bin/bash

# Get the name of the repo folder
repo_folder=$(basename "$(git rev-parse --show-toplevel)")

# Remove anything not alphanumeric and spaces (keeping '-' and '_'), and convert to lowercase
container_prepend=$(echo $repo_folder | sed -e 's/[^[:alnum:]_-]//g' | tr '[:upper:]' '[:lower:]')

# Add the '-app' affix
container_name="${container_prepend}-app"

# Filter for the container with that name, return id
# Assume there's only one result, which is always true for dev I think
command="docker container ls --filter name=$container_name --format {{.ID}}"
execute_command=$($command)

# Get the first instance of the running containers
container_id=$(echo "$execute_command" | head -n 1)

# For other scripts like ./attach.sh that rely on this script to work, this can be the only echo in this script
echo $container_id
