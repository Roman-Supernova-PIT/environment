#!/usr/bin/bash

# First time through creat your local venv copy with
# python -m venv --system-site-packages /home/venv
# source /home/venv/bin/activate

# image=/data/snpit/roman-snpit-env-cpu-0.1.36.sif
image=/data/snpit/roman-snpit-env-cuda-dev-0.1.36.sif
# image=/data/snpit/roman-snpit-env-cpu-0.1.41.sif

apptainer exec \
    --overlay pit_overlay.img \
    --cleanenv \
    --bind "${PWD}:/home" \
    --bind "${HOME}/snpit/secrets:/secrets:ro" \
    --bind "/mnt/roman-science-east-2/snpit/scratch/phrosty_dia_out:/dia_out_dir" \
    --bind "/mnt/roman-science-east-2/snpit/scratch/phrosty_lc_out:/lc_out_dir" \
    --bind "/mnt/roman-science-east-2/snpit/scratch/phrostyscratch:/snpit_temp" \
    --bind "/mnt/roman-science-east-2/snpit/scratch/phrostyscratch:/scratch" \
    --bind "/mnt/roman-science-east-2/snpit/scratch/sidecar_dia_out:/sidecar_dia_out:rw" \
    --bind "/data/snpit:/data_snpit" \
    --bind "/data/snpit/database_dirs_rknop_dev/images:/data/images:ro" \
    --bind "/home/rkessler:/rick:ro" \
    --bind "/mnt/roman-science-east-2/snpit/snana+romanisim+romancal:/ricksims:ro" \
    --pwd /home \
    --env SNPIT_DEFAULT_CONFIG=/home/environment/smdc_dev_config.yaml \
    --env SNPIT_CONFIG=/home/environment/smdc_dev_config.yaml \
    ${image} \
    /bin/bash "${@}"
