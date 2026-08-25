#!/usr/bin/bash

bash ./launch_container.sh \
     --bind /data=/pscratch/sd/m/masao/roman_snpit \
     -d /configs/rknop_dev_container_config.yaml \
     -c /configs/rknop_dev_container_config.yaml \
     --require-system nersc \
     ${@}
