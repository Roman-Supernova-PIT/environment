# See README.rst in the docker subdirectory of the git repo
#   for documentation on building the docker images.
#
#
# MANUALLY BUILDING
#
# Build this in the top-level checkout of environment with
#
#   DOCKER_BUILDKIT=1 docker build --build-arg "IMAGE_TYPE=cpu" --target snpit_env -t <tag> -f docker/Dockerfile .
#
# * replace <tag> with the name of the Docker image.  (For NERSC, Rob uses:
#       registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu
#   replacing cpu with cpu-dev, cuda, or cuda-dev as appropriate.)
#
# * replace "IMAGE_TYPE=cpu" with "IMAGE_TYPE=cuda" to get an image that
#   includes cuda libraries.

ARG IMAGE_TYPE=cpu

# As of this writing (2026-10-14, corresponding to version 0.X.X of the
# environent), here are the sizes of the various build stages:
#
# IMAGE_TYPE=cpu :
#   cpu-base          0.88GB
#   cpu-build-base    1.43GB
#   pip-install-cpu   3.17GB
#   compilations      3.17GB
#   snpit_env         2.59GB   (all those pip packages bloat a lot even without the build deps)
#   snpit_dev_env     3.14GB
#
# IMAGE_TYPE=cuda
#   cpu-base            0.88GB
#   cuda-base           4.52GB   (!!!) (inorite?)
#   cuda-build-base    10.0 GB   (!!!!!)
#   pip-install-cpu    11.8 GB
#   pip-install-cuda   12.2 GB
#   compilations       12.2 GB
#   snpit_env           6.66GB
#   snpit_dev_env      12.2 GB


# ======================================================================
# This is the base target for CPU images (i.e. ones that don't include
# cuda libraries).

FROM debian:trixie-20260112 AS cpu-base

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
         hdf5-tools \
         less \
         libfftw3-bin \
         libhdf5-310 \
         locales \
         postgresql-client \
         procps \
         python3 \
         rlwrap \
         scamp \
         socat \
         source-extractor \
         swarp \
         tmux \
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

# Try to make PyPi really think fftw3 is installed
RUN ln -s /usr/lib/x86_64-linux-gnu/libfftw3.so.3 /usr/lib/libfftw3.so

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
         nvidia-driver-cuda \
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
       libtool \
       nsight-systems-2025.3.2 \
       nsight-compute-2025.3.0 \
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

# This next symbolic link is needed by our tests.  Most of the
#   time it will just be a broken link that we can ignore.
RUN ln -s /home/photometry_test_data /photometry_test_data

# Config files
#   snpit_pipeline_config.yaml has default config for all pipeline processes,
#     but no system info (paths, database)
#   snpit_test_config.yaml has the databases and paths used by the
#     environment defined in test-docker-environment
#   test_config_for_db.yaml has the configuration used for the database
#     server in the test environment in test-docker-environment
COPY default_snpit_pipeline_config.yaml /default_snpit_pipeline_config.yaml
COPY snpit_test_config.yaml /snpit_test_config.yaml
COPY test-docker-environment/test_config_for_db.yaml /test_config_for_db.yaml

# ======================================================================
FROM ${IMAGE_TYPE}-build-base AS snpit_dev_env

# Copy the virtual environment from the pip-install stage
COPY --from=compilations /venv /venv
COPY --from=compilations /roman_imsim /roman_imsim

# Make sure that we'll use the python from that environment
ENV PATH="/venv/bin:$PATH"

# Make sure roman_imsim is in the python path.
ENV PYTHONPATH=/roman_imsim

# This next symbolic link is needed by our tests.  Most of the
#   time it will just be a broken link that we can ignore.
RUN ln -s /home/photometry_test_data /photometry_test_data

# Copy the default SNPIT config, plus two used by tests
COPY default_snpit_pipeline_config.yaml /default_snpit_pipeline_config.yaml
COPY snpit_test_config.yaml /snpit_test_config.yaml
COPY test-docker-environment/test_config_for_db.yaml /test_config_for_db.yaml
