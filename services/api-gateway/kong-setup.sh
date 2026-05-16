#!/bin/bash
# Kong Gateway Setup Script

echo "Setting up Kong Gateway..."

# Wait for Kong to be ready
until curl -s http://localhost:8001/status | grep -q '"database":{"reachable":true}'; do
  echo "Waiting for Kong to be ready..."
  sleep 2
done

echo "Kong is ready!"

# Create JWT plugin configuration
echo "Configuring JWT authentication..."

# Note: JWT configuration is already in kong.yml
# This script can be used for additional setup

echo "Kong Gateway setup complete!"
echo "Access Kong Admin API at: http://localhost:8001"
echo "Access Kong Proxy at: http://localhost:8000"

