# Dockerfile for nnUNet base images
# Author: Ashis Ravindran, DKFZ
# Builds image nvidia/cuda:11.8.0-runtime-ubuntu22.04
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# Maintainer information
LABEL maintainer="ashis.ravindran@dkfz-heidelberg.de"
LABEL version="1.0"
LABEL description=""
LABEL image.source=""
LABEL image.revision="commit-sha"
LABEL image.version="tag-or-version"
ENV PYTHONUNBUFFERED=1

# Set defaults for build arguments
ARG USER_UID=2323
ARG USER_GID=2323

# Create non-root user and group, and prevent login
RUN groupadd -g $USER_GID eucaim && \
    useradd -l -r -u $USER_GID -g eucaim -d /home/eucaim -m -s /usr/sbin/nologin eucaim

RUN apt-get update && apt-get install -y --no-install-recommends\
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Python3 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Install PyTorch+CUDA
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torch==2.7.1 torchvision==0.22.1 --index-url https://download.pytorch.org/whl/cu118

WORKDIR /app
RUN mkdir -p nnunetv1

# Copy relevant files
COPY start_nnunet.sh ./start_nnunet.sh
COPY health_check.py ./health_check.py
COPY nnUNet nnunetv1

RUN chown -R root:root /app && chmod 755 ./start_nnunet.sh

# Install nnU-Net
RUN pip3 install --no-cache-dir -e ./nnunetv1

# Switch to eucaim user
USER eucaim
WORKDIR /home/eucaim

# Set env vars required by nnU-Net
ENV nnUNet_input="/home/eucaim/nnUNet_input" 
ENV nnUNet_output="/home/eucaim/nnUNet_output"
ENV RESULTS_FOLDER="/home/eucaim/nnUNet_results_folder"

RUN mkdir -p $nnUNet_input $nnUNet_output $RESULTS_FOLDER

