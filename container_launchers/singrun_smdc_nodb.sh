#!/usr/bin/bash

launch_script_dir=$(dirname $([ -L $0 ] && readlink -f $0 || echo $0))
bash "${launch_script_dir}"/launch_container.sh \
     --bind /data=$PWD/data \
     -d /snpit_env_base/configs/container_nodb.yaml \
     -c /snpit_env_base/configs/container_nodb.yaml \
     --require-system smdc-east-1 \
     ${@}
