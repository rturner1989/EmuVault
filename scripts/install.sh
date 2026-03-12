#!/bin/bash
set -e

echo ""
echo "================================"
echo "  EmuVault Setup"
echo "================================"
echo ""

# Check dependencies
if ! command -v docker &> /dev/null; then
  echo "ERROR: Docker is not installed. Please install Docker and try again."
  exit 1
fi

if ! docker compose version &> /dev/null; then
  echo "ERROR: Docker Compose is not available. Please install Docker Compose and try again."
  exit 1
fi

# Create .env from example if it doesn't exist, generating secure credentials
if [ ! -f ".env" ]; then
  echo "Generating .env with secure credentials..."

  DB_PASSWORD=$(openssl rand -base64 24 | tr -d '=/+' | head -c 32)
  ADMIN_PASSWORD=$(openssl rand -base64 24 | tr -d '=/+' | head -c 32)

  sed \
    -e "s/DB_PASSWORD=emuvault/DB_PASSWORD=${DB_PASSWORD}/" \
    -e "s/ADMIN_PASSWORD=changeme/ADMIN_PASSWORD=${ADMIN_PASSWORD}/" \
    .env.example > .env

  echo ".env created with randomly generated credentials."
  echo ""
  echo "  DB password:    ${DB_PASSWORD}"
  echo "  Admin password: ${ADMIN_PASSWORD}"
  echo "  Admin email:    admin@emuvault.local"
  echo ""
  echo "  (these are saved in your .env file — keep it safe)"
  echo ""
else
  echo "Using existing .env file."
  echo ""
fi

echo "Building Docker containers (this may take a few minutes)..."
docker compose build

echo ""
echo "Starting database and Redis..."
docker compose up -d postgres redis
sleep 5

echo ""
echo "Creating database..."
docker compose run --rm app bin/rails db:create

echo ""
echo "Running migrations..."
docker compose run --rm app bin/rails db:migrate

echo ""
echo "Seeding database..."
docker compose run --rm app bin/rails db:seed

echo ""
echo "Stopping background services..."
docker compose down

echo ""
echo "================================"
echo "  Setup complete!"
echo "================================"
echo ""
echo "To start EmuVault, run:"
echo ""
echo "  docker compose up"
echo ""
echo "Then open http://localhost:3000 in your browser."
echo ""
