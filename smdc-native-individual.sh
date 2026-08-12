SNPIT_DIR=${HOME}/snpit/packages

if [ x"$DEV_STORAGE" = "x" ]; then
    export DEV_STORAGE=/mnt/roman-science-internal/snpit/users/${LOGNAME}/dev_storage
fi
sg snpit -c "mkdir -p $DEV_STORAGE"

# Activate Python venv
source ${SNPIT_DIR}/snpit-photometry/bin/activate

# Set YAML configuration
export SNPIT_DEFAULT_CONFIG=${SNPIT_DIR}/env/configs/smdc_native_config.yaml
export SNPIT_CONFIG=${SNPIT_DEFAULT_CONFIG}

# Set locations that CRDS wants
export CRDS_SERVER_URL=https://roman-crds.stsci.edu
export CRDS_PATH=${HOME}/crds_cache

# Create a package definition dir env to be able to look up location of photometry_test_data
export SNPIT_PHOTOMETRY_TEST_DATA_DIR=${SNPIT_DIR}/photometry_test_data

# Then if you want to use a particular package sidecar, phrosty, campari
# check it out in ${SNPIT_DIR} and then "pip install -e ."
