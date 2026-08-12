#!/bin/bash
# 2026-08-10, Lauren Aldoroty
#
# Activate a shared environment suitable for Roman SNPIT tools on SMDC
# Currently targeted at photometry packages: sidecar, phrosty, campari
#
# You will run these commands whenever you want to activate the shared environment:

mkdir -p /mnt/roman-science-internal/snpit/${LOGNAME}/temp_dir

if [ x"$DEV_STORAGE" = "x" ]; then
    export DEV_STORAGE=/mnt/roman-science-internal/snpit/users/${LOGNAME}/dev_storage
fi
sg snpit -c "mkdir -p $DEV_STORAGE"

source /data/snpit/env/environment_checkout_for_native/smdc-native-shared.sh

SNPIT_DIR=/data/snpit
export SNPIT_DEFAULT_CONFIG=${SNPIT_DIR}/env/configs/smdc_native_config.yaml
export SNPIT_CONFIG=${SNPIT_DEFAULT_CONFIG}

export SNPIT_PHOTOMETRY_TEST_DATA_DIR=${SNPIT_DIR}/photometry_test_data
