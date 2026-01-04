#!/bin/bash
set -e

echo "Waiting for CodeDeploy agent to be active..."
until systemctl is-active --quiet codedeploy-agent; do
  sleep 5
done

echo "Waiting for Docker service to be active..."
until systemctl is-active --quiet docker; do
  sleep 5
done

echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region eu-north-1 | \
docker login --username AWS --password-stdin \
266735802734.dkr.ecr.eu-north-1.amazonaws.com

echo "Pulling latest Docker image from ECR..."
docker pull \
266735802734.dkr.ecr.eu-north-1.amazonaws.com/food_delivery_time_prediction:latest

echo "Stopping old container if it exists..."
docker stop app || true
docker rm app || true

echo "Starting new container..."
docker run -d \
  --name app \
  -p 80:8000 \
  266735802734.dkr.ecr.eu-north-1.amazonaws.com/food_delivery_time_prediction:latest

echo "Deployment completed successfully."
