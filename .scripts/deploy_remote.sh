#!/bin/bash
set -e

echo "Setting up smallweb user..."

# Create a system user for smallweb
useradd --user-group --create-home --shell "$(which bash)" --uid 1000 smallweb || echo "User smallweb already exists"

# Create a SSH key for the smallweb user
mkdir -p /home/smallweb/.ssh
cp /root/.ssh/authorized_keys /home/smallweb/.ssh/authorized_keys
ssh-keygen -t ed25519 -N "" -f /home/smallweb/.ssh/id_ed25519 -q || true
chown -R smallweb:smallweb /home/smallweb/.ssh

echo "Setting up Docker Compose project..."

# Create directory structure
mkdir -p /opt/docker/smallweb
cd /opt/docker/smallweb

# Copy docker-compose.yml from temp
cp /tmp/docker-compose.yml ./docker-compose.yml

# Create necessary directories
mkdir -p data
chown -R smallweb:smallweb data

# Start Smallweb
docker compose up -d

echo "🎉 Smallweb is running!"
docker compose ps