## Install a development environment suitable for Roman SNPIT tools on SMDC
# Currently targeted at photometry packages: sidecar, phrosty, campari
#
# This script only needs to be run once to set up the environment, and then you can activate it with
# source snpit-photometry/bin/activate
#
# In brief, this install script:
#
# 1. Sets some variables based on how you ran the script
# 2. Temporarily goes into a pre-existing venv to get a current-enough version of python
# 3. Create Python venv
# 4. pip install Roman SN PIT prereqs and snappl into this venv
# 5. Creates a launcher script

# Figure out the user config

rundir=${RUNDIR:-${HOME}/snpit}
envname=${ENVNAME:-snpit-env}
dev_storage=${DEV_STORAGE:-/mnt/roman-science-internal/snpit/users/${LOGNAME}/dev_storage}
snpit_scratch=${SNPIT_SCRATCH:/dev/shm}

# Make sure we've got a default config

if [ x"$SNPIT_DEFAULT_CONFIG" = "x" ]; then
   echo "Must set SNPIT_DEFAULT_CONFIG to set up an environment"
   exit 1
fi

# Don't clobber any directories or script files
if [ -e ${rundir}/${envname} ]; then
    echo "${rundir}/${envname} already exists, not overwriting."
    exit 1
fi

if [ -e ${rundir}/launch_${envname}.sh ]; then
    echo "${rundir}/launch_{$envname}.sh already existings, not overwriting."
    exit 1
fi
   
# Temporarily go into one of our standard environments just to get a usable python
source /data/snpit/env/environment_checkout_for_native/smdc-native-shared.sh

# Now we can just create our Python env from the Python that is available in the miniconda3 spack module
# We don't need to actually conda install anything.

# Go into ${rundir} and make the environment
mkdir -p ${rundir}
cd ${rundir}
python -m venv ${envname}

# Deactivate the standard environment we temporarily went into
deactivate

# Now activate the Python venv
source ${envname}/bin/activate

# Doesn't matter, but pip is updated frequently and whenever you run pip
# it will bug you to update it, so we can do that once to avoid those pestering messages for a little bit.
pip install --upgrade pip

# First time this will take ~10 minute as it installs all the dependencies of roman-snpit-snappl]
pip install -r /data/snpit/env/environment_checkout_for_native/requirements-cpu.txt

# You have to separately install roman_imsim because it is not in PyPi
# and thus we can't make it a dependency of snappl
# because PyPi wouldn't accept dependencies to non-published packages
pip install git+https://github.com/matroxel/roman_imsim.git@21ea15a

# If you want cupy, you have to explicitly install it
# because it's not a dependency of our photometry codes, 
# which can be run under either numpy or cupy
# You need to be on a GPU machine to install cupy
# We currently (2026-08-11) use cupy-cuda12x for the GPU machines at SMDC
# pip install cupy-cuda12x

# Some of the package specify a towncrier dependency, some don't
# Since you are likely setting up a development environment here go ahead and
# install things that will be needed or useful in development
# Used in the dev workflow
pip install pytest
pip install ruff
pip install towncrier

# Create the launcher script
cd ${rundir}
cat > launch_${envname}.sh<<EOF
#!/bin/bash

cd ${rundir}

export SNPIT_SCRATCH=${snpit_scratch}
export DEV_STORAGE=${dev_storage}
export SNPIT_DEFAULT_CONFIG=${SNPIT_DEFAULT_CONFIG}
export CRDS_SERVER_URL=https://roman-crds.stsci.edu
exprot CRDS_PATH=\$\{HOME\}/crds_cache

mkdir -p \$\{SNPIT_SCRATCH\}
mkdir -p \$\{DEV_STORAGE\}

source ${envname}/bin/activate

EOF
