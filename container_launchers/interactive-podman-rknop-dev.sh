#!/usr/bin/bash

bash $(dirname $0)/launch_container.sh \
     --bind /data=/pscratch/sd/m/masao/roman_snpit/database_dirs_rknop_dev \
     -d /snpit_env_base/configs/rknop_dev_container_config.yaml \
     -c /snpit_env_base/configs/rknop_dev_container_config.yaml \
     --require-system nersc \
     ${@}
