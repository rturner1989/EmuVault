#!/bin/bash
set -e

IMAGE="rturner1989/emuvault:latest"

echo "Building production image..."
docker build -f Dockerfile.prod -t "$IMAGE" .

echo ""
echo "Pushing to Docker Hub..."
docker push "$IMAGE"

echo ""
echo "Done! Image pushed: $IMAGE"
echo ""
echo "To update on TrueNAS Scale:"
echo "  Apps > emuvault > Stop > Pull Image > Start"
