#!/bin/bash

# builds image that will run on any platfrom

# Variables (customize these)
IMAGE_NAME="supersqa/demostore-wordpress"
TAG="v2-6.6"  # Or any other tag you prefer
PLATFORMS="linux/amd64,linux/arm64"  # Specify the platforms

# Check if Docker Buildx is installed
if ! docker buildx version > /dev/null 2>&1; then
  echo "Docker Buildx is not installed or enabled. Please enable Buildx."
  exit 1
fi

# Create a new builder instance if one doesn’t already exist
docker buildx create --use --name multiarch-builder || docker buildx use multiarch-builder

# Ensure the builder supports multi-platform
docker buildx inspect multiarch-builder --bootstrap

# Build and push the image for multiple platforms
docker buildx build --platform $PLATFORMS -t $IMAGE_NAME:$TAG --push .
