#!/bin/bash

# Translate missing/changed English locale keys to fr, de, es, it
# Uses the claude CLI (authenticated via login, no API key needed)
#
# Usage:
#   scripts/translate.sh          # translate new/changed keys
#   scripts/translate.sh --force  # re-translate everything

set -e

cd "$(dirname "$0")/.."

ruby lib/tasks/translate.rb "$@"
