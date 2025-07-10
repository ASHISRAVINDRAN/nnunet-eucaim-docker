# Dockerfile for nnUNet task-based images
# Author: Ashis Ravindran, DKFZ
# Builds image prebuilt ubuntu-python-pytorch image provided by the CHAIMELEON project.
# See https://github.com/chaimeleon-eu/workstation-images for more details.

ARG CUDA_VERSION=""
ARG BASE_VERSION="unknown"
FROM harbor.chaimeleon-eu.i3m.upv.es/chaimeleon-library-batch/ubuntu-python-pytorch:${BASE_VERSION}${CUDA_VERSION}
ARG TASK_NAME

USER chaimeleon:chaimeleon
WORKDIR /home/chaimeleon

# Set env vars required by nnU-Net
ENV nnUNet_input="/home/chaimeleon/nnUNet_input" 
ENV nnUNet_output="/home/chaimeleon/nnUNet_output"
ENV RESULTS_FOLDER="/home/chaimeleon/nnUNet_results_folder"
ENV TASK_NAME=$TASK_NAME

# Create those dirs
RUN mkdir -p $nnUNet_input $nnUNet_output $RESULTS_FOLDER nnunetv1

# Copy relevant files
COPY start_nnunet.sh ./start_nnunet.sh
COPY nnUNet nnunetv1

# Install nnU-Net
RUN pip3 install -e ./nnunetv1

# Download task
RUN echo "Downloading $TASK_NAME" && /home/chaimeleon/.local/bin/nnUNet_download_pretrained_model $TASK_NAME

CMD ["/bin/bash", "./start_nnunet.sh" ]

# Commands:
# docker build -t nnunetv1:heart --build-arg TASK_NAME=Task002_Heart --build-arg CUDA_VERSION=cuda11 --build-arg BASE_VERSION=3.10 .
# docker run -v /home/a178n/DKFZ/eucaim_work/test_input:/home/chaimeleon/nnUNet_input -v /home/a178n/DKFZ/eucaim_work/test_out:/home/chaimeleon/nnUNet_output --gpus all nnunetv1:heart 
