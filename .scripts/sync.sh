#!/bin/bash

# Sync local files to Smallweb server
echo "🔄 Syncing files to Smallweb server..."

# Get server IP
DROPLET_IP=$(mise run get-ip)

# Sync files using rsync through root SSH access
rsync -avz --delete \
  --exclude='.DS_Store' \
  --exclude='node_modules' \
  --exclude='*.log' \
  --exclude='.env' \
  -e "ssh -i ~/.ssh/id_ed25519_do" \
  ./ root@$DROPLET_IP:/opt/docker/samllweb/data

echo "✅ Sync complete!"
