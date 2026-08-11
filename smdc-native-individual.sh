SNPIT_DIR=${HOME}/snpit/packages

# Activate Python venv
source ${SNPIT_DIR}/snpit-photometry/bin/activate

# Set YAML configuration
export SNPIT_DEFAULT_CONFIG=${SNPIT_DIR}/environment/smdc_native_config.yaml
export SNPIT_CONFIG=${SNPIT_DEFAULT_CONFIG}

# Create a package definition dir env to be able to look up location of photometry_test_data
export SNPIT_PHOTOMETRY_TEST_DATA_DIR=${SNPIT_DIR}/photometry_test_data
