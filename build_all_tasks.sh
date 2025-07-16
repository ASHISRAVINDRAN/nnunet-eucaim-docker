#!/bin/bash

# List TASK_NAMES here
TASK_NAMES=(
  Task002_Heart
)

# Build base image first
docker build \
    -t "nnunet:base" nnunet-base/
echo "nnUNet base image build finshed"

# Build each task-specific image
for TASK_NAME in "${TASK_NAMES[@]}"; do
  echo "Building image for: $TASK_NAME"
  
  docker build \
    --build-arg TASK_NAME=$TASK_NAME \
    -t "nnunetv1:${TASK_NAME}" nnunet-task/
    
  echo "Building finshed for image: $TASK_NAME"
done
