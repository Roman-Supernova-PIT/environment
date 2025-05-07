# BUILDING
#
# You need the nvidia runtime to build.  That is extremely annoying,
#   because as far as I can tell, there's no way to specify that at run
#   time, but you have to change the system default.  This is what Rob
#   has to do on his desktop to make this happen:
#   * Edit /etc/docker/daemon.json
#   * Add a just after the last thing inside the outermost {}
#   * On the line before the last } (but after the comman you just added), add:
#       "default-runtime": "Nvidia"
#   * Stop and restart the docker dameon with /etc/init.d/docker restart
#   * Remember later after you're done building to undo the damage
#     you just did to your system.
#
# Build this in the top-level checkout of environment with
#
#   DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cpu" --target snpit_env -t <tag> -f docker/Dockerfile .
#
# * replace <tag> with the name of the Do0cker image.  (For NERSC, Rob uses:
#       registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu
#   replacing cpu with cpu-dev, cuda, or cuda-dev as appropriate.)
#
# * replace "IMAGE_TYPE=cpu" with "IMAGE_TYPE=cuda" to get an image that
#   includes cuda libraries.

ARG IMAGE_TYPE=cpu

# As of this writing, here are the sizes of the various build stages:
#
# IMAGE_TYPE=cuda :
#   cpu-base          879MB
#   cpu-build-base    1.57GB
#   pip-install-cpu   3.29GB
#   compilations      3.29GB
#   snpit_env         2.58GB   (all those pip packages bloat a lot even without the build deps)
#   snpit_dev_env     3.27GB
#
# IMAGE_TYPE=cuda
#   cpu-base           879MB
#   cuda-base          3.5GB   (!!!) (inorite?)
#   cuda-buiold-base   6.75GB  (!!!!!)
#   pip-install-cpu    8.48GB
#   pip-install-cuda   8.71GB
#   compilations       8.71GB
#   snpit_env          5.43GB
#   snpit_dev_env      8.68GB


# ======================================================================
# This is the base target for CPU images (i.e. ones that don't include
# cuda libraries).

FROM rknop/devuan-daedalus-rknop AS cpu-base

LABEL maintainer="Rob Knop <raknop@lbl.gov>"

SHELL [ "/bin/bash", "-c" ]

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Make sure .debs are up to date, install additional things we globally
#   need, including enough cuda packages for runtime.  Clean up all apt
#   cache afterwards for space reasons.

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install \
         lsb-release \
         curl \
         emacs-nox \
         git \
         less \
         libfftw3-bin \
         locales \
         python3 \
         scamp \
         source-extractor \
         swarp \
         tzdata \
         unzip \
         vim-nox \
         wget \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Make sure the en_US.UTF8 locale is the default
RUN cat /etc/locale.gen | perl -pe 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' > /etc/locale.gen.new \
    && mv /etc/locale.gen.new /etc/locale.gen \
    && locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# principle of least surprise
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN ln -s /usr/bin/SWarp /usr/bin/swarp
RUN ln -s /usr/bin/source-extractor /usr/bin/sextractor

# Some basic configs for sanity
ENV LESS=-XLRi


# ======================================================================
# This is the base target for building cuda-based images.  It builds off
# of the CPU base, so we don't have to repeat all the stuff that's done
# there.

FROM cpu-base AS cuda-base

# Add the nvidia cuda apt archive
RUN cat /etc/apt/sources.list | perl -pe 's/main$/main non-free contrib/' > /etc/apt/sources.list.new \
   && mv /etc/apt/sources.list.new /etc/apt/sources.list
COPY docker/cuda-archive-keyring.gpg /usr/share/keyrings/cuda-archive-keyring.gpg
COPY docker/nvidia-container-toolkit-keyring.gpg /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
COPY docker/cuda-debian12-x86_64.list /etc/apt/sources.list.d/cuda-debian12-x86_64.list
COPY docker/nvidia-container.list /etc/apt/source.list.d/nvidia-container.list

# Set some nvidia-related environment variables
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_REQUIRE_CUDA="cuda>=8.0"

# Install some basic runtime Cuda packages.  This already bloats the
# image more than I'd like, but by not including the full Cuda dev
# environment, we save a couple of GB.  NOTE: even though you'd think
# cudart-dev should only be in the build image, at least one file from
# it is needed by pycuda

RUN apt-get update \
    && apt-get -y install \
         cuda-cudart-12-4 \
         cuda-cudart-dev-12-4 \
         cuda-nvrtc-12-4 \
         libcublas-12-4 \
         libcudnn9-cuda-12 \
         libcufft-12-4 \
         libcurand-12-4 \
         libcusolver-12-4 \
         libcusparse-12-4 \
         libnvidia-ml1 \
         libnvjitlink-12-4 \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Make sure that the cuda stuff is in the path
ENV PATH=/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# LD_LIBRARY_PATH is very complicated; see the README.md file.
# Have to have the /usr/lib/x86_64-linux-gnu first to stop things from
#   finding the stub libcuda.so in /usr/local/cuda/lib64/stubs
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs

# ======================================================================
# Install compilers and stuff that will be needed for building CPU stuff.

FROM cpu-base AS cpu-build-base

# EDITORS NOTE: make sure that the packages in the cuda-build-base stage
#   below are a superset of the packages here.

RUN apt-get update && \
    apt-get -y install -y \
       autoconf \
       autotools-dev \
       cmake \
       cython3 \
       g++ \
       gdb \
       gfortran \
       libbz2-dev \
       libtool \
       pkg-config \
       python3-pip \
       python3-venv \
       valgrind \
    && apt-get -y autoremove \
    && apt-get clean


# ======================================================================
# Install compilers and stuff that will be needed for building,
# including building Cuda stuff.  This has some redundancy with
# cpu-build-base, but there's no clean way in multi-stage Docker builds
# to do the kind of multiple inheritance necessary to accomplish what we
# need here.

FROM cuda-base AS cuda-build-base

# EDITORS NOTE: Make sure that the packages below are a superset of the
#   packges in the cpu-build-base stage above, and that the things here
#   that aren't there are all cuda-related.

RUN apt-get update && \
    apt-get -y install -y \
       autoconf \
       autotools-dev \
       cmake \
       cuda-command-line-tools-12-4 \
       cuda-minimal-build-12-4 \
       cython3 \
       g++ \
       gdb \
       gfortran \
       libbz2-dev \
       libcublas-dev-12-4 \
       libcudnn9-dev-cuda-12 \
       libcufft-dev-12-4 \
       libcurand-dev-12-4 \
       libcusolver-dev-12-4 \
       libcusparse-dev-12-4 \
       libnvidia-ml-dev \
       libtool \
       pkg-config \
       python3-pip \
       python3-venv \
       valgrind \
    && apt-get -y autoremove \
    && apt-get clean


# ======================================================================
# This is the stage that tries to install an environment similar to the
# conda environment defined in sn_pit_dev.yaml.  Using conda in docker
# files is... fraught.  The image size is unnecessarily large.
# conda-pack is a solution, but it seems to choke when you use both
# conda and pip to install packages.  Since most things in
# sn_pit_dev.yaml are actually installed with pip, just use pip here,
# with the usual pip multi-stage solution of not keeping all
# the build dependencies.

FROM ${IMAGE_TYPE}-build-base AS pip-install-cpu

RUN mkdir /usr/src/pip-install
WORKDIR /usr/src/pip-install

# Make the venv we'll copy out of this build stage
RUN mkdir /venv
RUN python3 -mvenv /venv

# Copy in the requirements (which is the same file included by
# sn_pit_dev.yaml.)
COPY requirements-cpu.txt .

# Install pip packages.
RUN source /venv/bin/activate \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements-cpu.txt

# ======================================================================
# Add the pip packages needed for the cuda image

FROM pip-install-cpu AS pip-install-cuda

WORKDIR /usr/src/pip-install

# Copy in the requirements (which is the same file included by
# sn_pit_dev.yaml.)
COPY requirements-cuda.txt .

RUN source /venv/bin/activate \
    && pip install --no-cache-dir -r requirements-cuda.txt


# ======================================================================
# Compile additional things

FROM pip-install-${IMAGE_TYPE} AS compilations

WORKDIR /usr/src

# Note: as of this writing, the roman_imsim archive has both a branch
#   and a tag "v2.0".  That caused the git archive command to choke.
#   So, we use the specific git commit hash as the argument to git
#   archive.  (As of this writing, this version (or, presumably, later)
#   is needed, at least, for phrosty.)
RUN git clone https://github.com/matroxel/roman_imsim.git \
  && mkdir /roman_imsim \
  && cd roman_imsim \
  && git archive 21ea15a | tar -x -C /roman_imsim  \
  && cd .. \
  && rm -rf roman_imsim


# ======================================================================
FROM ${IMAGE_TYPE}-base AS snpit_env

# Copy the virtual environment from the pip-install stage
COPY --from=compilations /venv /venv
COPY --from=compilations /roman_imsim /roman_imsim

# Make sure that we'll use the python from that environment
ENV PATH="/venv/bin:$PATH"

# Make sure roman_imsim is in the python path.
ENV PYTHONPATH=/roman_imsim


# ======================================================================
FROM ${IMAGE_TYPE}-build-base AS snpit_dev_env

# Copy the virtual environment from the pip-install stage
COPY --from=compilations /venv /venv
COPY --from=compilations /roman_imsim /roman_imsim

# Make sure that we'll use the python from that environment
ENV PATH="/venv/bin:$PATH"

# Make sure roman_imsim is in the python path.
ENV PYTHONPATH=/roman_imsim
