#!/bin/sh
set -e

echo "Starting deployment..."

npx hardhat run scripts/deploy.js --network docker
