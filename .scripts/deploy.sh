#!/bin/bash

set -e

echo "🚀 Deploying Smallweb to DigitalOcean Droplet..."

# Check if droplet already exists
DROPLET_ID=$(doctl compute droplet list --format ID,Name --no-header | grep -w "$DROPLET_NAME" | awk '{print $1}' || true)

if [ -z "$DROPLET_ID" ]; then
  echo "📦 Creating new droplet..."

  # Create droplet with Docker pre-installed
  DROPLET_ID=$(doctl compute droplet create "$DROPLET_NAME" \
    --image "$IMAGE" \
    --size "$SIZE" \
    --region "$REGION" \
    --ssh-keys $(doctl compute ssh-key list --format ID --no-header | head -1) \
    --wait \
    --format ID \
    --no-header)

  echo "✅ Droplet created with ID: $DROPLET_ID"
else
  echo "🔄 Using existing droplet ID: $DROPLET_ID"
fi

# Get droplet IP
DROPLET_IP=$(mise run get-ip)
echo "📍 Droplet IP: $DROPLET_IP"

# Wait for droplet to be ready
echo "⏳ Waiting for droplet to be ready..."
sleep 30

# Deploy Smallweb via SSH
echo "📤 Setting up Smallweb on droplet..."

# Copy necessary files to droplet
echo "📋 Copying files to droplet..."
scp -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} docker-compose.yml root@$DROPLET_IP:/tmp/docker-compose.yml
scp -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} .scripts/deploy_remote.sh root@$DROPLET_IP:/tmp/deploy_remote.sh

# Execute deployment script
ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} root@$DROPLET_IP "chmod +x /tmp/deploy_remote.sh && /tmp/deploy_remote.sh"

echo "✅ Deployment complete!"
echo "🌐 Your Smallweb instance is running on: $DROPLET_IP"
echo ""
echo "📝 Add this to your ~/.ssh/config to connect:"
echo ""
echo "Host $DOMAIN"
echo "  User _"
echo "  Port 2222"
echo "  RequestTTY yes"
echo "  LogLevel ERROR"
echo ""
echo "💡 Point your domain $DOMAIN to $DROPLET_IP"
echo ""
echo "🔗 Then connect with: ssh $DOMAIN"
