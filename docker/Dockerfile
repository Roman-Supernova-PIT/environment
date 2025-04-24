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
#  DOCKER_BUILDKIT=1 docker build --target snpit_env -t <tag> -f docker/Dockerfile .
#
#  ( For NERSC, Rob uses registry.nersc.gov/m4385/rknop/roman-snpit-env:runtime )

# ======================================================================
# This is the base target for building the image.  Rather than
# use the nvidia images (which are huge), maye a (probably futile)
# attempt to have smaller docker images by starting from
# a base Linux distro and installing just the cuda packages we need.
#
# I'm still unhappy about how big this image is at the end.  A bunch
# of it is unavoidable given the pip packages we install and how
# big they are (nearly 2GB of stuff).
#
# One thing to look out for : later, pip may install all
# the nvidia libraries itself!  You may need to do fancy
# things to get cuda-aware pip packages to use already-installed
# nvidia libraries.


# The base image (in the first FROM statement) is the Daedalus release
# of Devuan.  Devuan is a close derivative of Debian that isn't based on
# systemd.  I strongly suspect that the Dockerfile would build if we
# used the corresponding Debian base image.  To see the mapping of
# Debian and Devuan versions, see: https://www.devuan.org/os/releases
#
# This base devuan image should exist on docker.io, so things should
# "just work".  However, in the unlikely even that you you have to build
# it, you can do so on a Linux machine.
#
#   1. Pull the image
#        sudo debootstrap --verbose --include=iputils-ping daedalus ./devuan-image http://pkgmaster.devuan.org/merged
#
#   2. chroot into the image, do any updates etc. that you want (as root!)
#        (For this image, I did basically nothing.)
#
#   3. Make sure to do `apt clean` and `rm -rf /var/lib/apt/lists` to reduce image bloat
#
#   4. Exit chroot
#
#   5. Make Docker image:
#        cd devuan-image
#        sudo tar cpf - . | docker import - <imagename>
#      where <imagename> is where the image will live.  (I used
#      <imagename>=rknop/devuan-daedalus-rknop, but you shouldn't use
#      exactly that as you won't be able to push to my repo on
#      docker.io.)
#
#   6. Push the docker image as necessary.

FROM rknop/devuan-daedalus-rknop AS base

LABEL maintainer="Rob Knop <raknop@lbl.gov>"

SHELL [ "/bin/bash", "-c" ]

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC


# Add the nvidia cuda apt archive
RUN cat /etc/apt/sources.list | perl -pe 's/main$/main non-free contrib/' > /etc/apt/sources.list.new \
   && mv /etc/apt/sources.list.new /etc/apt/sources.list
COPY docker/cuda-archive-keyring.gpg /usr/share/keyrings/cuda-archive-keyring.gpg
COPY docker/nvidia-container-toolkit-keyring.gpg /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
COPY docker/cuda-debian12-x86_64.list /etc/apt/sources.list.d/cuda-debian12-x86_64.list
COPY docker/nvidia-container.list /etc/apt/source.list.d/nvidia-container.list

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_REQUIRE_CUDA="cuda>=8.0"

# Make sure .debs are up to date, install additional things we globally
#   need, including enough cuda packages for runtime.  Clean up all apt
#   cache afterwards for space reasons.

# NOTE: even though you'd think cudart-dev should only
#   be in the build image, it's needed by pycuda

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install \
         lsb-release \
         curl \
         emacs-nox \
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

ENV PATH=/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs

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
# Install compilers and stuff that will be needed for building,
#   including cuda dev libraries.  This can also be used
#   as a base for a "devel" image that has all this stuff included.
# Including all this makes the docker image much bigger (+3.2GB)

FROM base AS buildbase

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
       git \
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

FROM buildbase AS pip-install

RUN mkdir /usr/src/pip-install
WORKDIR /usr/src/pip-install

# Make the venv we'll copy out of this build stage
RUN mkdir /venv
RUN python3 -mvenv /venv

# Copy in the requirements (which is the same file included by
# sn_pit_dev.yaml.)
COPY requirements.txt .

# Install pip packages.
RUN source /venv/bin/activate \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt


# ======================================================================
# Compile additional things

FROM pip-install AS compilations

WORKDIR /usr/src

# Note: as of this writing, the roman_imsim archive has both a branch
#   and a tag "v2.0".  That caused the git archive command to choke.
#   So, we use the specific git commit hash as the argument to git
#   archive.  (As of this writing, this version (or, presumably, later)
#   is needed, at least, for phrosty.)
RUN git clone https://github.com/matroxel/roman_imsim.git \
  && mkdir /roman_imsim \
  && cd roman_imsim \
  && git archive 74a9053 | tar -x -C /roman_imsim  \
  && cd .. \
  && rm -rf roman_imsim

# ======================================================================
FROM base AS snpit_env

# Copy the virtual environment from the pip-install stage
COPY --from=compilations /venv /venv
COPY --from=compilations /roman_imsim /roman_imsim

# Make sure that we'll use the python from that environment
ENV PATH="/venv/bin:$PATH"

# Make sure roman_imsim is in the python path.
ENV PYTHONPATH=/roman_imsim

# ======================================================================
FROM buildbase AS snpit_dev_env

# Copy the virtual environment from the pip-install stage
COPY --from=compilations /venv /venv
COPY --from=compilations /roman_imsim /roman_imsim

# Make sure that we'll use the python from that environment
ENV PATH="/venv/bin:$PATH"

# Make sure roman_imsim is in the python path.
ENV PYTHONPATH=/roman_imsim
