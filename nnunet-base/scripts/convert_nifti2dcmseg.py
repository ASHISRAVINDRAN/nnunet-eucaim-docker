import shutil
import os
import json
import random
from pathlib import Path
import SimpleITK as sitk
import numpy as np
from subprocess import PIPE, run
from os.path import join, exists

execution_timeout = 1200
convert_to = ".dcm"
dataset_dir = os.getenv("nnUNet_output")
nnunet_input_dir = os.getenv("nnUNet_input")

def _count_labels_in_nifti(nifti_path):
    nifti_image = sitk.ReadImage(nifti_path)
    data = sitk.GetArrayFromImage(nifti_image)
    unique_labels = np.unique(data)
    labels = unique_labels[unique_labels != 0]  # Exclude background (0)
    return len(labels)

def update_mitk_json_object(json_dict: Path):
    def random_color():
        return [random.random(), random.random(), random.random()]
    file = json_dict['groups'][0]['_file']

    n_labels = _count_labels_in_nifti(file)
    print("Number of labels:", n_labels)
    labels = [
        {
            "color": random_color(),
            "locked": True,
            "name": f"Label {label}",
            "opacity": 0.6,
            "tracking_id": str(label),
            "value": label,
            "visible": True
        }
        for label in range(1, n_labels + 1)
    ]
    json_dict['groups'][0]['labels'] = labels


def convert_to_dcmseg(json_file_path: Path):
    with open(json_file_path, 'r') as f:
        json_dict = json.load(f)

    #add labels info into the json dict
    update_mitk_json_object(json_dict)

    # write back with label info
    with open(json_file_path, 'w') as file:
        json.dump(json_dict, file, indent=4)

    # get nifti file name
    file = Path(json_dict['groups'][0]['_file'])
    output_filepath = json_file_path.parent.parent
    dcm_output_filepath = join(
        output_filepath, Path(file.stem).stem + convert_to
    )
    if not exists(dcm_output_filepath):
        command = [
            "/app/mitk/apps/MitkFileConverter.sh",
            "-i",
            json_file_path,
            "-o",
            dcm_output_filepath
        ]
        print(command)
        output = run(
            command,
            stdout=PIPE,
            stderr=PIPE,
            universal_newlines=True,
            timeout=execution_timeout,
        )

        print("\nStandard Output:")
        print(output.stdout)
        print("\nStandard Error (if any):")
        print(output.stderr)

if __name__ == "__main__":
    nnUNet_seg_dir = Path(dataset_dir).joinpath('tmp')
    mitk_json_filepaths = list(nnUNet_seg_dir.rglob("*.mitklabel.json"))
    for mitk_json_file in mitk_json_filepaths:
        convert_to_dcmseg(mitk_json_file)
    shutil.rmtree(nnUNet_seg_dir) # delete tmp directory

    nnUNet_data_dir = Path(nnunet_input_dir).joinpath('nnunet_data_dir')
    shutil.rmtree(nnUNet_data_dir)
