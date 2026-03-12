#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /emu-vault/tmp/pids/server.pid

exec "$@"
