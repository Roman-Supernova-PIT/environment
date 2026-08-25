#!/usr/bin/bash

bash ./launch_container.sh \
     --bind /data=/pscratch/sd/m/masao/roman_snpit/database_dirs \
     -d /configs/nov2025_container_config.sh \
     -c /configs/ou2024_container_config.sh \
     --require-system nersc \
     ${@}
