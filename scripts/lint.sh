#!/bin/bash

# Get the app container ID
container_id=$("$(dirname "$0")/get_app_container_id.sh")

echo "Running linters in app container $container_id..."

PASS=0
FAIL=0

run_check() {
  local name="$1"
  local cmd="$2"
  echo ""
  echo "▶  $name"
  echo "───────────────────────────────────────────────"
  if docker exec -it "$container_id" bash -c "$cmd"; then
    echo "✓  $name passed"
    PASS=$((PASS + 1))
  else
    echo "✗  $name failed"
    FAIL=$((FAIL + 1))
  fi
}

run_check "RuboCop"       "bundle exec rubocop -A"
run_check "HAML Lint"     "bundle exec haml-lint app/"
run_check "Brakeman"      "bundle exec brakeman --no-pager -q"
run_check "Bundler Audit" "bundle exec bundler-audit check --update"

echo ""
echo "═══════════════════════════════════════════════"
echo "  Results: $PASS passed, $FAIL failed"
echo "═══════════════════════════════════════════════"

[ $FAIL -eq 0 ]
