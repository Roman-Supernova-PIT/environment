SHELL_NAME=$(echo $SHELL | sed "s/\/bin\///g")

if [[ $(hostname -A) == *"duke"* ]]
then
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
elif [[ $(hostname -A) == *"nersc"* ]]
then
    module load conda/Mambaforge-23.1.0-1
    
    export PIT_ROOT=/global/cfs/cdirs/m4385/
    # DIFFERENCE IMAGING
    export SN_INFO_DIR="/pscratch/sd/l/laldorot/object_tables" # Location of object/image tables.
    export SIMS_DIR="/global/cfs/cdirs/lsst/shared/external/roman-desc-sims/Roman_data" # Location of the Roman-DESC sims.
    export SNANA_PQ_DIR="/global/cfs/cdirs/lsst/www/DESC_TD_PUBLIC/Roman+DESC/PQ+HDF5_ROMAN+LSST_LARGE" # Location of the SNANA parquet files.
    export DIA_OUT_DIR="/pscratch/sd/l/laldorot/dia_out" # Parent output folder for DIA pipeline.
    export NVCC="/opt/nvidia/hpc_sdk/Linux_x86_64/23.9/cuda/12.2/bin/nvcc" # `whereis nvcc` path
    # SNANA+Pippin
    export ROMAN_SNPIT="/global/cfs/cdirs/m4385"
    export SNANA_ROMAN_ROOT="$ROMAN_SNPIT/snana_roman_root"
    
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/global/common/software/nersc/pe/conda/23.6.0/Mambaforge-23.1.0-1/bin/conda' 'shell.$SHELL_NAME' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/global/common/software/nersc/pe/conda/23.6.0/Mambaforge-23.1.0-1/etc/profile.d/conda.sh" ]; then
            . "/global/common/software/nersc/pe/conda/23.6.0/Mambaforge-23.1.0-1/etc/profile.d/conda.sh"
        else
            export PATH="/global/common/software/nersc/pe/conda/23.6.0/Mambaforge-23.1.0-1/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
else
    echo "Unsure what machine you are on. Contact Ben Rose." >&2
fi



conda activate $PIT_ROOT/conda_env/envs/sn-pit-dev
