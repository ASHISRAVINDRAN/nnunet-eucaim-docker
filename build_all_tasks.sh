#!/bin/bash

# List TASK_NAMES here
TASK_NAMES=(
  Task002_Heart
  Task004_Hippocampus
)

# User UID and Group ID defaults
UID=${1:-1000}
GID=${2:-1000}

# Build base image first
docker build \
    --build-arg USER_UID=$UID\
    --build-arg USER_GID=$GID\
    -t "nnunet:base" nnunet-base/
echo "nnUNet base image build finshed"

# Build each task-specific image
for TASK_NAME in "${TASK_NAMES[@]}"; do
  echo "Building image for: $TASK_NAME"
  
  docker build \
    --build-arg TASK_NAME=$TASK_NAME \
    -t "nnunet:${TASK_NAME}" nnunet-task/
    
  echo "Building finshed for image: $TASK_NAME"
done
