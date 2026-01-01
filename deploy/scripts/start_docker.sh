#!/bin/bash
# ================================
# LOG EVERYTHING
# ================================
exec > /home/ubuntu/start_docker.log 2>&1
echo "===== START DOCKER SCRIPT ====="
date

# ================================
# VARIABLES
# ================================
REGION="eu-north-1"
ACCOUNT_ID="266735802734"
IMAGE_NAME="food_delivery_time_prediction"
IMAGE_TAG="latest"
CONTAINER_NAME="delivery_time_pred"

IMAGE_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}"

# ================================
# CHECK DISK
# ================================
echo "Disk usage:"
df -h

# ================================
# LOGIN TO ECR (WITH SUDO)
# ================================
echo "Logging in to ECR..."
sudo aws ecr get-login-password --region "$REGION" | \
sudo docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

# ================================
# CLEAN OLD DOCKER DATA (SAFE)
# ================================
echo "Cleaning docker junk..."
sudo docker system prune -f || true

# ================================
# PULL IMAGE
# ================================
echo "Pulling Docker image..."
sudo docker pull "$IMAGE_URI"

# ================================
# STOP & REMOVE OLD CONTAINER
# ================================
echo "Checking for existing container..."
sudo docker stop "$CONTAINER_NAME" || true
sudo docker rm "$CONTAINER_NAME" || true

# ================================
# START NEW CONTAINER
# ================================
echo "Starting new container..."
sudo docker run -d \
  --restart always \
  -p 80:8000 \
  --name "$CONTAINER_NAME" \
  -e DAGSHUB_USER_TOKEN="$DAGSHUB_USER_TOKEN" \
  "$IMAGE_URI"

# ================================
# VERIFY
# ================================
echo "Running containers:"
sudo docker ps

echo "Local health check:"
curl http://localhost || true

echo "===== CONTAINER STARTED SUCCESSFULLY ====="
