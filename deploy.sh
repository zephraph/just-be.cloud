#!/bin/bash

set -e

DROPLET_NAME="smallweb"
DOMAIN="just-be.cloud"
SSH_KEY_NAME="default"
REGION="nyc3"
SIZE="s-1vcpu-1gb"
IMAGE="docker-20-04"

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
DROPLET_IP=$(doctl compute droplet get "$DROPLET_ID" --format PublicIPv4 --no-header)
echo "📍 Droplet IP: $DROPLET_IP"

# Wait for droplet to be ready
echo "⏳ Waiting for droplet to be ready..."
sleep 30

# Deploy code via SSH
echo "📤 Deploying code to droplet..."

# Create deployment script
cat > /tmp/deploy_remote.sh << 'EOF'
#!/bin/bash
set -e

# Stop existing container if running
docker stop smallweb || true
docker rm smallweb || true

# Pull latest code (assuming you'll push to a git repo)
if [ ! -d "/root/smallweb" ]; then
  git clone https://github.com/zephraph/smallweb.git /root/smallweb
else
  cd /root/smallweb && git pull
fi

cd /root/smallweb

# Build and run container
docker build -t smallweb .
docker run -d \
  --name smallweb \
  --restart unless-stopped \
  -p 80:7777 \
  -p 443:7777 \
  -e SMALLWEB_DOMAIN=just-be.cloud \
  smallweb

echo "🎉 Smallweb is running!"
docker ps | grep smallweb
EOF

# Copy and execute deployment script
scp -o StrictHostKeyChecking=no /tmp/deploy_remote.sh root@$DROPLET_IP:/tmp/
ssh -o StrictHostKeyChecking=no root@$DROPLET_IP 'chmod +x /tmp/deploy_remote.sh && /tmp/deploy_remote.sh'

# Clean up
rm /tmp/deploy_remote.sh

echo "✅ Deployment complete!"
echo "🌐 Your app should be available at: http://$DROPLET_IP"
echo "💡 Don't forget to point your domain $DOMAIN to $DROPLET_IP"