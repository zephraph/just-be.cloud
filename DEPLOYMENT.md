# Deployment Guide for Smallweb on DigitalOcean

This guide explains how to deploy Smallweb as a Docker container to DigitalOcean App Platform with Cloudflare as the frontend.

## Prerequisites

1. DigitalOcean account with App Platform access
2. GitHub repository (fork or push this code)
3. Cloudflare account with just-be.cloud domain
4. DigitalOcean Container Registry (optional, for private images)

## Setup Instructions

### 1. DigitalOcean Setup

1. Create a new App on DigitalOcean App Platform:
   ```bash
   doctl apps create --spec app.yaml
   ```

2. Note the App ID from the output

3. Create the following GitHub Secrets in your repository:
   - `DIGITALOCEAN_ACCESS_TOKEN`: Your DigitalOcean API token
   - `DIGITALOCEAN_APP_ID`: The App ID from step 2
   - `DIGITALOCEAN_REGISTRY`: Your registry name (if using DO Container Registry)

### 2. Cloudflare Configuration

1. Add your domain `just-be.cloud` to Cloudflare

2. Configure DNS records:
   - Type: `A`, Name: `@`, Content: `<DigitalOcean App IP>`
   - Type: `CNAME`, Name: `*`, Content: `just-be.cloud`

3. Enable Cloudflare proxy (orange cloud) for SSL/TLS

4. SSL/TLS Settings:
   - Set SSL/TLS encryption mode to "Flexible" or "Full"
   - Enable "Always Use HTTPS"

### 3. Optional: Cloudflare Tunnel Setup

For enhanced security without exposing the DO instance IP:

1. Install cloudflared on your local machine
2. Create a tunnel:
   ```bash
   cloudflared tunnel create smallweb-tunnel
   ```

3. Configure the tunnel to point to your DigitalOcean app
4. Update DNS to use the tunnel instead of direct IP

## Local Testing

Test the setup locally before deploying:

```bash
# Build and run with docker-compose
docker-compose up --build

# Or manually with Docker
docker build -t smallweb-local .
docker run -p 80:7777 -v $(pwd):/smallweb smallweb-local
```

## Deployment

Push to the main branch to trigger automatic deployment:

```bash
git add .
git commit -m "Deploy Smallweb to DigitalOcean"
git push origin main
```

## Verifying Deployment

1. Check GitHub Actions for successful workflow run
2. Monitor DigitalOcean App Platform deployment status
3. Test your sites:
   - Main: https://just-be.cloud
   - Subdomains: https://www.just-be.cloud, https://esm.just-be.cloud

## Troubleshooting

- **Port Issues**: Ensure DigitalOcean is configured to route port 80/443 to container port 7777
- **Subdomain Issues**: Verify wildcard CNAME record in Cloudflare
- **SSL Issues**: Check Cloudflare SSL/TLS settings match your setup

## Environment Variables

The following environment variables are set in the deployment:
- `SMALLWEB_DOMAIN`: just-be.cloud
- `PORT`: 7777 (internal container port)

## Notes

- All smallweb apps in this directory become subdomains (e.g., `www/` → `www.just-be.cloud`)
- Cloudflare handles SSL termination, so the container only needs HTTP
- The wildcard CNAME ensures all subdomains route correctly