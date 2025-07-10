#!/bin/bash

# modify filename as nnUNet for mono-modal Nifti data
for file in "$nnUNet_input"/*.nii.gz; do
    filename=$(basename "$file")
    if [[ "$filename" == *_0000.nii.gz ]]; then
        continue
    fi
    base="${filename%.nii.gz}"
    new_name="${base}_0000.nii.gz"
    new_path="$nnUNet_input/$new_name"

    mv "$file" "$new_path"
    echo "Renamed $filename to $new_name"
done

/home/chaimeleon/.local/bin/nnUNet_predict -i $nnUNet_input -o $nnUNet_output -t $TASK_NAME -tr nnUNetTrainerV2 -p nnUNetPlansv2.1 -m 3d_fullres
