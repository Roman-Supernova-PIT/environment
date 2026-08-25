#!/usr/bin/bash

bash ./launch_container.sh \
     --bind /data=/mnt/roman-science-internal/snpit/database_dirs/ricksims_2026-08 \
     --bind /ricksims=/mnt/roman-science-east-2/snpit/snana+romanisim+romancal \
     --bind /ricktruth=/home/rkessler/romanisim/input_catalogs \
     -d /configs/smdc_ricksim_apptainer.yaml \
     -c /configs/smdc_ricksim_apptainer.yaml \
     --require-system smdc \
     ${@}
