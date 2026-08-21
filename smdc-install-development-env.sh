## Install a development environment suitable for Roman SNPIT tools on SMDC
# Currently targeted at photometry packages: sidecar, phrosty, campari
#
# Documentation of this script can be found in the "environment" chapter of the snappl documentation.
#
# This script only needs to be run once to set up the environment, and then you can activate it with
#   source <rundir>/launch_<envname>.sh
#
# where <rundir> is what you set RUNDIR to before running the install
# script (default: ${HOME}/snpit), and <envname> is what you set ENVNAME
# to before running the install script (default: snpit-env).
#
# In brief, this install script:
#
# 1. Sets some variables based on how you ran the script
# 2. Temporarily goes into a pre-existing venv to get a current-enough version of python
# 3. Create Python venv
# 4. Either use a .pth file to link back to the standard environment,
#    or pip install Roman SN PIT prereqs and snappl into this venv
# 5. Creates a launcher script

# Find out if we're creating a whole messy environment, or a linked environment

independent=0

if (( $# > 1 )); then
    echo "Usage: bash smdc-install-development-env.sh [--independent]"
    exit 1
elif (( $# == 1 )); then
    if [ $1 = "--independent" ]; then
        independent=1
    else
        echo "Usage: bash smdc-install-development-env.sh [--independent]"
        exit 1
    fi
fi

baselauncher=/data/snpit/env/${BASE_LAUNCHER:-venv_smdc_ricksim.sh}
rundir=${RUNDIR:-${HOME}/snpit}
envname=${ENVNAME:-snpit-env}
dev_storage=${DEV_STORAGE:-/mnt/roman-science-internal/snpit/users/${LOGNAME}/dev_storage}
snpit_scratch=${SNPIT_SCRATCH:-/dev/shm}

# Don't clobber any directories or script files
if [ -e ${rundir}/${envname} ]; then
    echo "${rundir}/${envname} already exists, not overwriting."
    exit 1
fi
if [ -e ${rundir}/launch_${envname}.sh ]; then
    echo "${rundir}/launch_${envname}.sh already existings, not overwriting."
    exit 1
fi

# If the user set a SNPIT_DEFAULT_CONFIG, use that. Otherwise, parse the base
# launcher to figure it out... unless the user didn't give us a base launcher,
# in which case use the "no database" default config.

if [ x"${SNPIT_DEFAULT_CONFIG}" == "x" ]; then
    if [ x"${BASE_LAUNCHER}" == "x" ] ; then
        default_config=/data/snpit/env/configs/smdc_nodb_native.yaml
    else
        default_config=`cat $baselauncher | perl -ne 'BEGIN { $lnch=-1 } if ( /^export\s+SNPIT_DEFAULT_CONFIG=([^\s]+)\s*$/ ) { $lnch=$1; } END { if ( $lnch==-1 ) { exit 1; } else { print($lnch); } }'`
        if [ $? != 0 ]; then
            echo "Failed to parse ${baselauncher} for SNPIT_DEFAULT_CONFIG; make sure it's really an env launcher!"
            exit 1
        fi
    fi
else
    default_config=$SNPIT_DEFAULT_CONFIG
fi

# Parse the base launcher to find the venv
if [ ! -f $baselauncher ]; then
   echo "Failed to find base launncher ${baselauncher}"
   exit 1
fi
activate=`cat $baselauncher | perl -ne 'BEGIN { $act=-1 } if ( /^source +(.*activate) *$/ ) { $act=$1; } END { if ( $act==-1 ) { exit 1; } else { print($act); } }'`
if [ $? != 0 ]; then
    echo "Failed to parse ${baselauncher} for venv directory; make sure it's really an env launcher!"
    exit 1
fi

echo "Making venv..."

# Temporarily go into one of our standard environments just to get a usable python.
# (The default python on SMDC isn't sufficient for what we need.)
source $activate

# Go into ${rundir} and make the environment
mkdir -p ${rundir}
cd ${rundir}
python -m venv ${envname}

# Deactivate the standard environment we temporarily went into
deactivate

if (( $independent == 1 )); then
    # For an independent environment, we're going to install everything

    # Now activate the new Python venv
    source ${envname}/bin/activate

    # First time this will take ~10 minute as it installs all the dependencies of roman-snpit-snappl]
    echo "Installing roman snpit requirmeents (slow!)..."
    pip install -r /data/snpit/env/environment_checkout_for_native/requirements-cpu.txt

    # You have to separately install roman_imsim because it is not in PyPi
    # and thus we can't make it a dependency of snappl
    # because PyPi wouldn't accept dependencies to non-published packages
    echo "Installing roman_imsim..."
    pip install git+https://github.com/matroxel/roman_imsim.git@21ea15a

    # If you want cupy, you have to explicitly install it
    # because it's not a dependency of our photometry codes,
    # which can be run under either numpy or cupy
    # You need to be on a GPU machine to install cupy
    # We currently (2026-08-11) use cupy-cuda12x for the GPU machines at SMDC
    # echo "installing cuda"
    # pip install cupy-cuda12x

    # Some of the package specify a towncrier dependency, some don't
    # Since you are likely setting up a development environment here go ahead and
    # install things that will be needed or useful in development
    # Used in the dev workflow
    echo "Installing a few dev tools..."
    pip install pytest
    pip install ruff
    pip install towncrier

    # Exit the pythnon venv
    deactivate

else
    # In our new environment, link back to the packages that were in the standard environment

    echo "Linking to the base environment..."

    # Go into the base enviornment
    source $activate

    # Now use the .pth file business to link the base envirnment's site-packages into the new environment
    basepkgs="$(python -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')"
    envpkgs="$(./${envname}/bin/python -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')"
    echo $basepkgs > $envpkgs/_base_packages.pth

    # Leave the base environment
    deactivate
fi

# Doesn't matter, but pip is updated frequently and whenever you run pip
# it will bug you to update it, so we can do that once to avoid those pestering messages for a little bit.
echo "Updating pip..."
source ${envname}/bin/activate
pip install --upgrade pip
deactivate

# Create the launcher script
echo "Creating launcher script..."
cd ${rundir}
cat > launch_${envname}.sh<<EOF
#!/bin/bash

export SNPIT_SCRATCH=${snpit_scratch}
export DEV_STORAGE=${dev_storage}
export SNPIT_DEFAULT_CONFIG=${default_config}
export CRDS_SERVER_URL=https://roman-crds.stsci.edu
export CRDS_PATH=\${HOME}/crds_cache

mkdir -p \${SNPIT_SCRATCH}
mkdir -p \${DEV_STORAGE}

source ${rundir}/${envname}/bin/activate

EOF

echo "...done."
