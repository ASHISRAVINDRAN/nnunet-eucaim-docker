# nnUNet EUCAIM Docker

This repository provides Docker images for running [nnUNet](https://github.com/MIC-DKFZ/nnUNet/tree/nnunetv1) inference in a reproducible and containerized environment, tailored for the EUCAIM project.

---

## 🛠️ Setup

To build all task-specific nnUNet images, run:

```bash
./build_all_tasks.sh
```

You may optionally specify the user UID and GID to avoid permission issues when running containers.

### Image Hierarchy
* `nnunet:base`: Built first, this image includes all the necessary environment dependencies. Uses the official NVIDIA CUDA Ubuntu 22.04 runtime: `nvidia/cuda:11.8.0-runtime-ubuntu22.04`.
* `nnunet:TaskXXX_*`: Built on top of `nnunet:base`, each task-specific image includes the corresponding pretrained model checkpoint (downloaded at build time).

## Usage
Each container expects two mounted directories for I/O:
* Input: `/home/eucaim/nnUNet_input`
* Output: `/home/eucaim/nnUNet_output`

Your `.nii.gz` files should be placed inside the input directory. The container processes them sequentially and writes the segmentation outputs to the output directory using the same filenames.

### Example

To run inference using the image for Task002_Heart, execute:
```bash
docker run \
  -v /host/data_input:/home/eucaim/nnUNet_input \
  -v /host/data_out:/home/eucaim/nnUNet_output \
  --gpus all \
  nnunet:Task002_Heart
```

## Data Format Conventions
* All input files must be 3D NIfTI files (.nii.gz).
* All files in the input folder will be processed in batch.
* Output files are written with identical filenames into the output folder.

### File Naming
nnUNet follows specific naming conventions, especially important for multi-modal tasks:

* Mono-modal tasks (e.g., `Task002_Heart`)
The container automatically adjusts file names if needed, so the user can provide files with simple names like `image01.nii.gz`.

* Multi-modal tasks (e.g., Task005_Prostate)
The user must provide input files named according to the expected modality format (e.g., `image_0000.nii.gz`, `image_0001.nii.gz`, etc.), corresponding to each input modality.

For detailed guidelines, refer to the [nnUNet data format documentation](https://github.com/MIC-DKFZ/nnUNet/blob/nnunetv1/documentation/data_format_inference.md).




