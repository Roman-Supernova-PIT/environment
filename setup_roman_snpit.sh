#! /usr/bin/env bash

SHELL_NAME=$(echo $SHELL | sed "s/\/bin\///g")

if [[ $(hostname -A) == *"duke"* ]]
then
    echo "ERROR, THIS IS NOT UP TO DATE AND NEEDS EDITING."
    exit 1
    module load Anaconda3/2024.02
    module load gsl
    module load ROOT

    export PIT_ROOT='/hpc/group/cosmology/roman-sn-pit'
    # RomanDESC sims
    export ROMAN_DESC_ROOTDIR='/cwork/mat90/RomanDESC_sims_2024/RomanTDS'
    export IMSUB_OUT='/hcp/group/cosmoloyg/roman-sn-pit/imsub_out'
    # SNANA+Pippin
    export SNDATA_ROOT='/hpc/group/cosmology/roman-sn-pit/SNANA/SNDATA_ROOT'
    export SNANA_DIR='/hpc/group/cosmology/roman-sn-pit/SNANA/SNANA'
    export SNANA_ROMAN_USERS='/hpc/group/cosmology/roman-sn-pit/SNANA/SURVEYS/ROMAN'
    export SCRATCH_SIMDIR=' /cwork/bmr14/SNANA/SCRATCH_SIMDIR/SIM'
    export PIPPIN_OUTPUT='/cwork/bmr14/SNANA/PIPPIN_OUTPUT'


    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/opt/apps/rhel9/Anaconda3-2024.02/bin/conda' 'shell.$SHELL_NAME' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/opt/apps/rhel9/Anaconda3-2024.02/etc/profile.d/conda.sh" ]; then
            . "/opt/apps/rhel9/Anaconda3-2024.02/etc/profile.d/conda.sh"
        else
            export PATH="/opt/apps/rhel9/Anaconda3-2024.02/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
elif [[ $(hostname -f) == *"nersc"* ]]
then
    module load conda

    export ROMAN_SNPIT="/global/cfs/cdirs/m4385"
    export PIT_ROOT=/global/cfs/cdirs/m4385/
    export PIT_ENV_DIR=${PIT_ROOT}/env

    # A user may have manually set SNPIT_CONFIG, or a wrapper script may have called
    #   this script and set SNPIT_CONFIG.  If the variable isn't set, set it to the
    #   default.
    if [[ -v SNPIT_CONFIG ]]; then
        echo "SNPIT_CONFIG is ${SNPIT_CONFIG}"
    else
        # Default config file for the default dev database.  If
        echo "Setting SNPIT_CONFIG to /dvs_ro/cfs/cdirs/m4385/env/configs/nov2025_nersc_native_config.yaml"
        export SNPIT_CONFIG="/dvs_ro/cfs/cdirs/m4385/env/configs/nov2025_nersc_native_config.yaml"
    fi

    # Default environment, used in case another wrapper shell didn't set this
    if [[ ! -v SNPIT_CONDA_ENV ]]; then
        export SNPIT_CONDA_ENV="snpit-env-dev"
    fi

    # SNANA
    export SNANA_ROMAN_ROOT="$ROMAN_SNPIT/snana_roman_root"

elif [[ $(hostname -A) == *"jupyter-"* ]] # should be on the Roman Science Platform
then
    echo "ERROR, THIS IS NOT UP TO DATE AND NEEDS EDITING."
    exit 1
    export PIT_ROOT="/teams/orca"
    # DIFFERENCE IMAGING
    export SN_INFO_DIR="/teams/orca/object_tables" # Location of object/image tables.
    export SIMS_DIR="s3://nasa-irsa-simulations/openuniverse2024/roman/preview" # Location of the Roman-DESC sims.
    export SNANA_PQ_DIR="/teams/orca/PQ+ROMAN+LSST_LARGE" # Location of the SNANA parquet files.
    export DIA_OUT_DIR="/teams/orca/dia_output" # Parent output folder for DIA pipeline.
else
    echo "Unsure what machine you are on. Contact Ben Rose or Rob Knop." >&2
    exit 1
fi




if [[ $(hostname -A) == *"jupyter-"* ]]
then
    echo "ERROR, THIS IS NOT UP TO DATE AND NEEDS EDITING."
    exit 1
    conda activate $PIT_ROOT/environment/envs/sn-pit-dev && ipython kernel install --user --name=sn-pit-dev
else
    conda activate $PIT_ENV_DIR/$SNPIT_CONDA_ENV
fi
