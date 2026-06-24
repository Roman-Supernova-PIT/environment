#!/usr/bin/bash

# First time through creat your local venv copy with
# python -m venv --system-site-packages /home/venv
# source /home/venv/bin/activate

# image=/data/snpit/roman-snpit-env-cpu-0.1.36.sif
# image=/data/snpit/roman-snpit-env-cuda-dev-0.1.41.sif
image=/data/snpit/roman-snpit-env-cpu-0.1.41.sif

apptainer exec \
    --overlay pit_overlay.img \
    --cleanenv \
    --mount type=bind,source=${PWD},target=/home \
    --mount type=bind,source=${HOME}/secrets,target=/secrets,readonly \
    --mount type=bind,source=/data/snpit,target=/data_snpit \
    --mount type=bind,source=/dev/shm,target=/snpit_temp \
    --mount type=bind,source=/data/snpit/sidecar_dia_out,target=/sidecar_dia_out \
    --mount type=bind,source=/data/snpit/database_dirs_rknop_dev/images,target=/data/images,readonly \
    --mount type=bind,source=/mnt/roman-science-east-2/snpit/scratch,target=/scratch \
    --pwd /home \
    --env SNPIT_DEFAULT_CONFIG=/home/environment/smdc_dev_config.yaml \
    --env SNPIT_CONFIG=/home/environment/smdc_dev_config.yaml \
    ${image} \
    /bin/bash "${@}"
