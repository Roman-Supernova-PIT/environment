#!/usr/bin/bash

launch_script_dir=$(dirname $([ -L $0 ] && readlink -f $0 || echo $0))
bash "${launch_script_dir}"/launch_container.sh \
     --bind /data=/mnt/roman-science-internal/snpit/database_dirs/ricksims_2026-08 \
     --bind /ricksims=/mnt/roman-science-east-2/snpit/snana+romanisim+romancal \
     --bind /ricktruth=/home/rkessler/romanisim/input_catalogs \
     -d /snpit_env_base/configs/smdc_ricksim_apptainer.yaml \
     -c /snpit_env_base/configs/smdc_ricksim_apptainer.yaml \
     --require-system smdc \
     ${@}
