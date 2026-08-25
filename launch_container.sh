#!/bin/bash

default_currentenvver=0.1.47
default_imageregistry=registry.nersc.gov/m4385
default_sifdir=/data/snpit

host_system=unknown
containersystem=unknown

if [[ `hostname -f | perl -pe '$_=substr $_,-11'` == '.nersc.gov' ]]; then
    host_system='nersc'
    containersystem='podman'
elif [[ `hostname -f | perl -ne 'exit(/\.(us-east-)/ ? 0 : 1)'` ]]; then
    host_system='smdc'
    containersystem='apptainer'
elif [[ ! x`which docker` == "x" ]]; then
    host_system='local docker host'
    containersystem='docker'
else
    echo "I cannot figure out which system you're on; tried nersc, SMDC, and a local machine running docker."
    exit 1
fi
echo "Host system is ${host_system}"

declare -A envvars
envvars["LD_LIBRARY_PATH"]="/usr/lib64:/usr/lib/x86_64-linux_gnu"
envvars["PYTHONPATH"]="/roman_imsim"
envvars["OPENBLAS_NUM_THREADS"]=1
envvars["MKL_NUM_THREADS"]=1
envvars["NUMEXPR_NUM_THREADS"]=1
envvars["OMP_NUM_THREADS"]=1
envvars["VECLIB_MAXIMUM_THREADS"]=1
envvars["XTERM"]=1
envvars["SNPIT_DEFAULT_CONFIG"]=no_config_set
envvars["SNPIT_CONFIG"]=no_config_set

declare -A bindmounts
bindmounts["/home"]=$PWD
bindmounts["/secrets"]=$HOME/secrets
bindmounts["/temp_dir"]=${SNPIT_SCRATCH:$PWD/temp_dir}
bindmounts["/dev_storage"]=${DEV_STORAGE:-$PWD/dev_storage}
bindmounts["/packages"]=$PWD/packages
bindmounts["/data"]=$PWD/data
bindmounts["/photometry_test_data"]=$PWD/packages/photometry_test_data

if [[ host_system == 'nersc' ]]; then
    bindmounts["/temp_dir"]=${SNPIT_SCRATCH:-$PSCRATCH/snpit_temp}
    bindmounts["/dev_storage"]=${DEV_STORAGE:-$PSCRATCH/snpit_devstorage}
    bindmounts["/scratch"]=$PSCRATCH
    bindmounts["/ou2024"]=/dvs_ro/cfs/cdirs/lsst/shared/external/roman-desc-sims/Roman_data
    bindmounts["/ou2024_snana_lc_dir"]=/dvs_ro/cfs/cdirs/lsst/www/DESC_TD_PUBLIC/Roman+DESC/ROMAN+LSST_LARGE_SNIa-normal
    bindmounts["/ou2024/sims_sed_library"]=/dvs_ro/cfs/cdirs/lsst/www/DESC_TD_PUBLIC/Roman+DESC/sims_sed_library
    bindmounts["/a25epsf"]=/dvs_ro/cfs/cdirs/m4385/calib_data/A25ePSF
elif [[ host_system == 'smdc' ]]; then
    bindmounts["/temp_dir"]=${SNPIT_SCRATCH:-/dev/shm/snpit_temp}
    bindmounts["/dev_storage"]=${DEV_STORAGE:-/mnt/roman-science-internal/snpit/users/${LOGNAME}/dev_storage}
    bindmounts["/photometry_test_data"]=/mnt/roman-science-internal/snpit/photometry_test_data
fi

testing=0
omgcuda=0
whichenv=cpu
runcommand=""
shellscript=""
currentenvver=""
imageregistry=""
sifdir=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --test)
            testing=1
            shift
            ;;
        -h|--help)
            echo
            echo "Usage: launch_container.sh [-w environment] [-v imageversion] [-e var=val] [-e var=val...] [-b target=source] [-b target=source...] [-c config] [-d defaultconfig] [-s shellscript] [-r ...]"
            echo "  -w ENV or --whichenv ENV : one of cpu, cpu-dev, cuda, or cuda-dev.  Defaults to cpu"
            echo "  -v VER, --version VER, or --image-version VER : the image version to run, default {$default_currentenvver}"
            echo "  -e VAR=VAL or --env VAR=VAL : set enviroment variable VAR to value VAL inside the container"
            echo "  -b TARGET=SOURCE or --bind TARGET=SOURCE or --bindmount TARGET=SOURCE: "
            echo "        Directory SOURCE on the host system is available at TARGET inside the container.  TARGET "
            echo "        must be an absolute path."
            echo "  -i LOCATION or --image-location LOCATION : the directory or docker regsitry to find the image. "
            echo "        defaults to ${default_imageregistry} for podman or docker, and to ${default_sifdir} "
            echo "        for apptainer."
            echo "  -c CONFIG or --config CONFIG : the SNPIT_CONFIG file to use.  Also sets "
            echo "        and SNPIT_DEFAULT_CONFIG unless you also give -d/--default-config."
            echo "  -d CONFIG or --default-config CONFIG : the SNPIT_DEFAULT_CONFIG file to use."
            echo "        Also sets SNPIT_CONFIG unless you also give -c/--config."
            echo "  -s SCRIPT or --shellscript SCRIPT : a bash script to run inside the container."
            echo "  -r ... or --run ... : bash commands to run inside the container.  Everything after -r or "
            echo "        --run is intereted as stuff to run in bash, and will not be parsed by this script. "
            echo
            echo "Note that if you give -e SNPIT_CONFIG=val, it may or may not override what you gave with -c; "
            echo "  the one that shows up latter in your command line wins.  Just don't do this to avoid confusion."
            echo
            echo "WARNING : do not have any single or double quotes (' or "'"'" or `) anywhere in your command line, "
            echo "  or things are likely to break horribly."
            exit 0
            ;;
        -w|--whichenv)
            if [[ $# -lt 2 ]]; then
                echo "Caommand line ended with -w or --whichenv, need argument"
                exit 1
            fi
            whichenv=$2
            shift
            shift
            ;;
        -v|--version|--image-version)
            if [[ $# -lt 2]];then
                echo "Command line ended with -v or --image-version, need argument"
                exit 1
            fi
            currentenvver=$2
            shift
            shift
            ;;
        -e|--env)
            if [[ $# -lt 2 ]]; then
                echo "Command line ended with -e or --env, need argument"
                exit 1
            fi
            varname=`echo $2 | perl -pe 's/=.+$//;'`
            varval=`echo $2 | perl -pe 's/^[^=]+=//;'`
            if [[ x"varname" == "x" || x"varval" == "x" ]]; then
                echo "Failed to parse --env {$2}"
                exit 1
            fi
            envvars[$varname]=$varval
            shift
            shift
            ;;
        -b|--bind|--bindmount)
            if [[ $# -lt 2 ]]; then
                echo "Command line ended with -b or --bind, need argument"
                exit 1
            fi
            target=`echo $2 | perl -pe 's/:.+$//;'`
            source=`echo $2 | perl -pe 's/^[^:]+://;'`
            if [[ x"target" == "x" || x"source" == "x" ]]; then
                echo "Failed to parse --bind {$2}"
                exit 1
            fi
            bindmounts[$target]=$source
            shift
            shift
            ;;
        -i|--image-location)
            if [[ $# -lt 2 ]]; then
                echo "Command line ended with -i or --image-location, need argument"
                exit 1
            fi
            imageregistry=$2
            sifdir=$2
            shift
            shift
            ;;
        -c|--config)
            if [[ $# -lt 2 ]]; then
                echo "Command line ended with -c or --config, need argument"
                exit 1
            fi
            envvars["SNPIT_CONFIG"]=$2
            if [[ ! -v envvars["SNPIT_DEFAULT_CONFIG"] ]]; then
                envvars["SNPIT_DEFAULT_CONFIG"]=$2
            fi
            shift
            shift
            ;;
        -d|--default-config)
            if [[ $# -lt 2 ]]; then
                echo "Command line ended with -d or --default-config, need argument"
                exit 1
            fi
            envvars["SNPIT_DEFAULT_CONFIG"]=$2
            if [[ ! -v envvars["SNPIT_CONFIG"] ]]; then
                envvars["SNPIT_CONFIG"]=$2
            fi
            shift
            shift
            ;;
        -s|--shellscript)
            if [[ $# -lt 2 ]]; then
                echo "Command line ended with -s or --shellscript, need argument"
                exit 1
            fi
            shellscript=$2
            shift
            shift
            ;;
        -r|--run)
            # This is the last argument parsed; EVERYTHING after -r or --run is interpreted as stuff
            #   to run underneath a bash -c
            shift
            while [[ $# -gt 0 ]]; do
                runcommand="${runcommand} $1"
                shift
            done
            ;;
    esac
done

# Fill in defaults
if (( ${#currentenvver} == 0 )); then
    currentenvver=$default_currentenvver
fi
if (( ${#imageregistry} == 0 )); then
    imageregistry=$default_imageregistry
fi
if (( ${#sifdir} == 0 )); then
    sifdir=$default_sifdir
fi

# Check for both -s and -r
if (( ( ${#runcommand} > 0 ) && ( ${#shellscript} > 0 ) )); then
    echo "Error, you gave both a --shellscript and a --run command, only give one."
    exit 1
fi

if [[ ( $whichenv = "gpu" ) || ( $whichenv = "gpu-dev" ) ]]; then
    omgcuda=1
    envvars["LD_LIBRARY_PATH"]="${envvars[LD_LIBRARY_PATH]}:/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs"
elif [[ ! ( ( $whichenv = "cpu" ) || ( $whichenv = "cpu-dev" ) ) ]]; then
    echo "Unknown environment ${whichenv}, must be one of cpu, cpu-dev, cuda, or cuda-dev"
    exit 1
fi


# Build the env string
envstring=""
for i in ${!envvars[@]}; do
    if (( ${#envstring} > 0 )); then
        envstring="${envstring} "
    fi
    if [[ ( $containersystem == "docker" ) || ( $containersystem == "podman" ) ||
          ( $constainersystem == "apptainer" ) ]]; then
        envstring="${envstring}--env ${i}=${envvars[$i]}"
    else
        echo "This should never happen. Error.  Dying."
        exit 1
    fi
done

# Build the bind mount string
bindmountstring=""
for i in ${!bindmounts[@]}; do
    if (( ${#bindmountstring} > 0 )); then
        bindmountstring="${bindmountstring} "
    fi
    if [[ ( $containersystem == "docker" ) || ( $containersystem == "podman" ) ]]; then
        bindmountstring="${bindmountstring}--mount type=bind,source=${bindmounts[$i]},target=$i"
    elif [[ $containersystem == "apptainer" ]]; then
        bindmountstring="${bindmountstring}--bind ${bindmounts[$i]}:$i"
    else
        echo "This should never happen.  Error.  Dying."
        exit 1
    fi
done


# Build the container launching command line

containerrun=""
if [[ ( $containersystem == "docker" ) || ( $containersystem == "podman" ) ]]; then
    if [[ $host_system == 'nersc' ]]; then
        containerrun="podman-hpc run "
    else
        containerrun="docker run "
    fi

    # Cuda
    if [[ $omgcuda == 1 ]];then
        if [[ $containersystem == 'podman' ]]; then
            containerrun="${containerrun} --gpu "
        else
            containerrun="${containerrun} --gpus=all "
        fi
    fi
    containerrun="${containerrun} ${bindmountstring} ${envstring} -w /home"

    # TODO: figure out if there's a docker equivalent
    if [[ $containersystem == "podman" ]]; then
        $containerrun="${containerrun} --annontation run.oci.keep_original_groups=1"
    fi

    if (( ( ${#runcommand} == 0 ) && ( ${#shellscript} == 0 ) )); then
        $containerrun="${containerrun} -it"
    fi

    $containerrun="${containerrun} ${imageregistry}/roman-snpit-env:${whichenv}-${currentenvver} /bin/bash"

elif [[ $containersystem == "apptainer" ]]; then
    $containerrun="apptainer run "

    # Set the overlay
    if [[ $host_system == 'smdc' ]]; then
        overlayname=/mnt/roman-science-internal/snpit/apptainer_overlays/${LOGNAME}/$RANDOM.img
    else
        echo "This should never happen.  Error.  Dying."
        exit 1;
    fi
    
    #Cuda
    if [[ $omgcuda == 1 ]]; then
        $containerrun="${containerrun} --nv"
    fi

    $containerrun="${containerrun} --cleanenv ${envstring} ${bindmountstring} --cwd /home"
    $containerrun="${containerrun} ${sifdir}/roman-snpit-env-${whicnenv}-${currentenvver}.sif /bin/bash"

fi

# shellscript and runcommand
if (( ${#shellscript} > 0 )); then
    $containerrun="${containerrun} ${shellscript}"
elif (( ${#runcommand} > 0 )); then
    $containerrun="${containerrun} -c '${runcommand}'"
fi

# Testing output
if [[ $testing == 1 ]]; then
    echo "Container run command would be is:\n${containerrun}\n"
    exit 0
fi

# ...ok, here we go

if [[ $host_system == 'smdc' ]]; then
    sg snpit -c "${containerrun}"
elif [[ $host_system == 'nersc' ]]; then
    /bin/bash -c "${containerrun}"
elif [[ $host_system == "local docker host" ]]; then
    /bin/bash -c "${containerrun}"
else
    echo "Unknown host system ${host_system}; you should never see this error, it should have died before."
    exit 1
fi

