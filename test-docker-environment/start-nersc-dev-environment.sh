#!/bin/sh

# ERROR -- this does not currently work.  Still trying to figure out how to get podman containers
#   running on nersc to network with each other.

# TO USE THIS:
#
# (1) You need to make sure that all the right images are built and pulled.  You will need the following
#     images:
#
#     * mailhog/mailhog:latest
#     * registry.nersc.gov/m4385/rknop/snpit-db-postgres:test20251031_2
#     * registry.nersc.gov/m4385/rknop/snpit-db-postgres:snpit-db-webserver-test:test20251031_2
#     * registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu
#
#     NOTES
#        * the "test20251031_2" will get updated regularly as things change!  Make sure you read
#          this file a lot and re-pull things as necessary.
#
#        * If instead of the cpu image you want the cuda-dev image, pull that.  Then, below,
#          find the variables WHICHENV and WITHGPU and swap the commented and uncommented versions.
#
# (2) Pick a directory to work.  Below, I will call this your "base dir"
#
# (3) In your base dir, git clone https://github.com/Roman-Supernova-PIT/environment.git
#
#     (Or git@github.com:Roman-Supernova-PIT/environment.git)
#
# (4) In your base dir, check out other things you might need, e.g. snappl, campari, phrosty, etc.
#
# (4) Make sure you don't have any podman running:
#
#      podman-hpc ps
#      podman-hpc ps -a
#
#    If the first command shows you stuff, you need to stop the running
#    containers (with podman-hpc stop <name or id>).  If the second
#    command shows you stuff, run:
#
#      podman-hpc prune
#
# (5) Start all the containers with:
#
#       bash start-nersc-dev-environment.sh
#
# (6) If all is well, you can now get into the enviornment with
#
#      podman-hpc exec -it shell /bin/bash
#
# (7) When you are done, exit out of the container and run
#
#      bash stop-nersc-dev-environment.sh



WHICHENV=cpu
# WHICHENV=cuda-dev
WITHGPU=""
# WITHGPU="--gpu"

# echo "Creating network"
# 
# podman-hpc network create -d bridge roman_snpit_dev_env_network


echo "Running mailhog"

podman-hpc run -d \
  --name=mailhog \
  --network=podman \
  mailhog/mailhog:latest

echo "Creating postgres data volume."

podman-hpc volume create roman-snpit-postgres-data

echo "Starting postgres container."

podman-hpc run -d \
  --name=postgres \
  --network=podman \
  --mount type=bind,source=secrets,target=/secrets \
  --volume roman-snpit-postgres-data:/var/lib/postgresql/data \
  --env PGPASSWDFILE=/secrets/roman_snpit_test_env_pgpasswd \
  --env PGPASSWDIFILE_RO=/secrets/roman_snpit_test_env_pgpasswd_ro \
  registry.nersc.gov/m4385/rknop/snpit-db-postgres:test20251031_2

echo "Sleeping 5s in hopes that that's enough for postgres to be going"
sleep 5

echo "Migrating database schema."

podman-hpc run -d \
  --name=createdb \
  --network=podman \
  --entrypoint python \
  registry.nersc.gov/m4385/rknop/snpit-db-webserver-test:test20251031_2 \
  -c "import snappl.db.migrations.apply_migrations as a; a.apply_migrations()"

echo "Starting webserver."

podman-hpc run -d \
  --name=webserver \
  --network=podman \
  --env SNPIT_CONFIG=/roman-snpit-db/config-test.yaml \
  registry.nersc.gov/m4385/rknop/snpit-db-webserver-test:test20251031_2

echo "Starting shell."

podman-hpc run ${WITHGPU} -d \
  --name=shell \
  --network=podman \
  --mount type=bind,source=secrets,target=/secrets \
  --mount type=bind,source=../../,target=/home \
  --mount type=bind,source=../../photometry_test_data,target=/photometry_test_data \
  --entrypoint /bin/bash \
  registry.nersc.gov/m4385/rknop/roman-snpit-env:${WHICHENV} \
  -c "ln -s /home/environment/test-docker-environment/default_test_config.yaml /default_test_config.yaml && tail -f /etc/issue"
