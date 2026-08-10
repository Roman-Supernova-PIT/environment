#!/usr/bin/bash

if [ "$WHICHROMANENV" = "cuda" ] || [ "$WHICHROMANENV" == "cuda-dev" ]; then
    echo "GPU not supported with singularity on SMDC"
    exit 1
fi

umask 002
sg snpit -c "mkdir -p /mnt/roman-science-internal/snpit/apptainer_overlays/${LOGNAME}"
overlayname=/mnt/roman-science-internal/snpit/apptainer_overlays/${LOGNAME}/smdc_ricksim_overlay_$RANDOM.img
sg snpit -c "apptainer overlay create --sparse --size 1024 $overlayname"

sg snpit -c "mkdir -p $PWD/crds_cache"

if [ x"$DEV_STORAGE" = "x" ]; then
    DEV_STORAGE=/mnt/roman-science-internal/snpit/users/${LOGNAME}/dev_storage
fi
sg snpit -c "mkdir $DEV_STORAGE"


sg snpit -c "
apptainer run \
    --overlay $overlayname \
    --cleanenv \
    --env LD_LIBRARY_PATH=/usr/lib64:/usr/lib/x86_64-linux-gnu:/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs \
    --env PYTHONPATH=/roman_imsim \
    --env OPENBLAS_NUM_THREADS=1 \
    --env MKL_NUM_THREADS=1 \
    --env NUMEXPR_NUM_THREADS=1 \
    --env OMP_NUM_THREADS=1 \
    --env VECLIB_MAXIMUM_THREADS=1 \
    --env TERM=xterm \
    --env SNPIT_DEFAULT_CONFIG=/snpit_env/configs/smdc_ricksim_apptainer.yaml \
    --env SNPIT_CONFIG=/snpit_env/configs/smdc_ricksim_apptainer.yaml \
    --env HOME=/home \
    --env CRDS_SERVER_URL=https://roman-crds.stsci.edu \
    --env CRDS_PATH=$HOME/crds_cache \
    --cwd /home \
    --bind $PWD:/home \
    --bind $PWD/packages:/packages \
    --bind $HOME/secrets:/secrets \
    --bind ${SNPIT_SCRATCH:-/dev/shm}:/snpit_temp \
    --bind $DEV_STORAGE:/dev_storage \
    --bind /data/snpit/env_for_apptainer:/snpit_env \
    --bind /mnt/roman-science-internal/snpit/database_dirs/ricksims_2026-08:/data \
    --bind /mnt/roman-science-east-2/snpit/snana+romanisim+romancal:/ricksims \
    --bind /home/rkessler/romanisim/input_catalogs:/ricktruth \
    /data/snpit/roman-snpit-env-${WHICHROMANENV:-cpu}-0.1.46.sif \
    /bin/bash ${@}
"

rm $overlayname

#   --overlay $HOME/smdc_ricksim_overlay.img \


# Need to figure out where these are
#     --bind /data/snpit/a25epsf:/a25epsf \
#     --bind /data/snpit/ou2024:/ou2024 \
#     --bind /data/snpit/ou2024_snana:/ou2024_snana \
#     --bind /data/snpit/ou2024_sims_sed_library:/ou2024_seds \
