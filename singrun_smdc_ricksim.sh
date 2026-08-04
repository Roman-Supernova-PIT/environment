#!/usr/bin/bash

if [ "$WHICHROMANENV" = "cuda" ] || [ "$WHICHROMANENV" == "cuda-dev" ]; then
    echo "GPU not supported with singularity on SMDC"
    exit 1
fi

if [ ! -f $HOME/smdc_ricksim_overlay.img ]; then
    echo "You need to create an overlay with:"
    echo "   apptainer overlay create --sparse --size 1024 $HOME/smdc_ricksim_overlay.img"
    exit 1
fi


singularity run \
    --overlay $HOME/smdc_ricksim_overlay.img \
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
    --bind $PWD:/home \
    --bind $HOME/secrets:/secrets \
    --bind ${SNPIT_SCRATCH:-/dev/shm}:/snpit_temp \
    --bind /data/snpit/env_for_apptainer:/snpit_env \
    --bind /data/snpit/a24epsf:/a254epsf \
    --bind /data/snpit/database_dirs_ricksim:/data \
    --bind /mnt/roman-science-east-2/snpit/snana+romanisim+romancal/output_images_2026-08_LBNL_mtg:/ricksims \
    --bind /home/rkessler/romanisim/input_catalogs/snana_sim_pilot+deep:/ricktruth \
    --bind /data/snpit/ou2024:ou2024 \
    --bind /data/snpit/ou2024_snana:ou2024_snana \
    --bind /data/snpit/ou2024_sims_sed_library:ou2024_seds \
    /data/snpit/roman-snpit-env-{$WHICHROMANENV:-cpu}-0.1.46.sif \
    /bin/bash ${@}
