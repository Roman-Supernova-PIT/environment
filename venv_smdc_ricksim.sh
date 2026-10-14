#!/bin/bash
# 2026-08-10, Lauren Aldoroty
#
# Activate a shared environment suitable for Roman SNPIT tools on SMDC
# Currently targeted at photometry packages: sidecar, phrosty, campari
#
# When you want to activate the shared environment, do this:
# source ${HOME}/snpit/packages/environment/environment_checkout_for_native/smdc-native-shared.sh 

mkdir -p /mnt/roman-science-internal/snpit/${LOGNAME}/temp_dir

if [ x"$DEV_STORAGE" = "x" ]; then
    export DEV_STORAGE=/mnt/roman-science-internal/snpit/users/${LOGNAME}/dev_storage
fi
sg supernovae -c "mkdir -p $DEV_STORAGE"

export SNPIT_DEFAULT_CONFIG=${HOME}/snpit/packages/environment/configs/smdc_ricksim_native.yaml
export SNPIT_CONFIG=${SNPIT_DEFAULT_CONFIG}

export CRDS_SERVER_URL=https://roman-crds.stsci.edu
export CRDS_PATH=${HOME}/crds_cache

export SNPIT_PHOTOMETRY_TEST_DATA_DIR=/data/snpit/photometry_test_data

source ${HOME}/snpit/snpit-env/bin/activate
