#!/bin/bash

# List TASK_NAMES here
TASK_NAMES=(
  Task002_Heart
)

CUDA_VERSION="cuda11"
BASE_VERSION="3.10"

# Build each task-specific image
for TASK_NAME in "${TASK_NAMES[@]}"; do
  echo "Building image for: $TASK_NAME"
  
  docker build \
    --build-arg TASK_NAME=$TASK_NAME \
    --build-arg CUDA_VERSION="$CUDA_VERSION" \
    --build-arg BASE_VERSION="$BASE_VERSION" \
    -t "nnunetv1:${TASK_NAME}" .
  echo "Building finshed for image: $TASK_NAME"
done
