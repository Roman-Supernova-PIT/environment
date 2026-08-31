#!/usr/bin/bash

launch_script_dir=$(dirname $([ -L $0 ] && readlink -f $0 || echo $0))
bash "${launch_script_dir}"/launch_container.sh \
     --bind /data=/pscratch/sd/m/masao/roman_snpit/database_dirs_rknop_dev \
     -d /snpit_env_base/configs/rknop_dev_container_config.yaml \
     -c /snpit_env_base/configs/rknop_dev_container_config.yaml \
     --require-system nersc \
     ${@}
