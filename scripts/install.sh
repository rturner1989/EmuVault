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

# Generate VAPID keys for web push if not already present
if ! grep -q "^VAPID_PUBLIC_KEY=.\+" .env 2>/dev/null; then
  echo ""
  echo "Generating VAPID keys for push notifications..."

  VAPID_OUTPUT=$(docker compose run --rm app bundle exec ruby -e '
require "openssl"
require "base64"
key       = OpenSSL::PKey::EC.generate("prime256v1")
pub_asn1  = OpenSSL::ASN1.decode(key.public_to_der)
pub_bytes = pub_asn1.value[1].value[1..]
outer      = OpenSSL::ASN1.decode(key.private_to_der)
ec_priv    = OpenSSL::ASN1.decode(outer.value[2].value)
priv_bytes = ec_priv.value[1].value
puts "VAPID_PUBLIC_KEY=#{Base64.urlsafe_encode64(pub_bytes, padding: false)}"
puts "VAPID_PRIVATE_KEY=#{Base64.urlsafe_encode64(priv_bytes, padding: false)}"
' 2>/dev/null)

  VAPID_PUB=$(echo "$VAPID_OUTPUT" | grep VAPID_PUBLIC_KEY)
  VAPID_PRIV=$(echo "$VAPID_OUTPUT" | grep VAPID_PRIVATE_KEY)

  sed -i \
    -e "s|^VAPID_PUBLIC_KEY=.*|${VAPID_PUB}|" \
    -e "s|^VAPID_PRIVATE_KEY=.*|${VAPID_PRIV}|" \
    .env

  echo "VAPID keys generated and saved to .env."
fi

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
