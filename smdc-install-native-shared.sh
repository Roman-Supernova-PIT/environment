#!/bin/bash
# 2026-08-10, Lauren Aldoroty
#
# Activate a shared environment suitable for Roman SNPIT tools on SMDC
# Currently targeted at photometry packages: sidecar, phrosty, campari
#
# When you want to activate the shared environment, do this:
# source /data/snpit/env/environment_checkout_for_native/smdc-install-native-shared.sh 
# DO NOT RUN THE BELOW STUFF. JUST SOURCE THIS FILE.

mkdir -p /mnt/roman-science-internal/snpit/${LOGNAME}/temp_dir

if [ x"$DEV_STORAGE" = "x" ]; then
    export DEV_STORAGE=/mnt/roman-science-internal/snpit/users/${LOGNAME}/dev_storage
fi
sg snpit -c "mkdir -p $DEV_STORAGE"

source /data/snpit/snpit-photometry/bin/activate
source /data/snpit/env/environment_checkout_for_native/smdc-native-shared.sh