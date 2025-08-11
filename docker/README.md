# Docker Image for Roman SN PIT

---

## Overview

The files in this directory are intended to be able to build docker images usable by all of the SN PIT.  These images, ideally, should work with `docker` on your local machine, with `podman-hpc` on perlmutter, with `apptainer` on other HPC clusters, and (somehow) on AWS (and probably other cloud providers).

There are four final images.  There are CPU and CUDA based images.  The CPU images do not include any CUDA libaries, and are a couple of GB smaller as a result.  For both CPU and CUDA, there are runtime and dev images.  The dev images include compilers, development libraries for linking, and some debug tools.  As a result, they're a few GB larger than the the runtime libraries.

Ideally, in production, we will use the runtime libraries, and you should test your code under the runtime libraries.  However, if you want to do any profiling, use the dev libraries.  If things aren't working with the runtime libraries, try the dev libraries, and then talk to Rob about what's necessary to change either in your code, or in the docker images, to make it all work.

---

## Using the Docker images

Ideally, you will not need to build the docker images yourself, but can use ones already built and pushed by Rob.  Exactly where you use them depends on the machine where you're running.

Note that if you're using `pycuda`, you may be stuck with using the full enormous `cuda-dev` image, as it seems not to work with just the `cuda` image.  Hopefully at some point Rob will figure out the minimum number of packages to move from the `cuda-dev` to the `cuda` image to make `pycuda` work without having to use the 10GB docker image.

Warning: these images are built on an x86_64 Linux machine.  If you're on an ARM Linux box, on an x86_64 Mac, or, heaven forbid, an ARM Mac, it's possible you will have problems.  (This is especially true with the Cuda images.)  While the obvious solution is to just get an x86_64 Linux desktop or laptop, you may be able to get things to work by just rebuilding the images yourself with docker.

If you're on Windows, then your best bet is to reformat your hard drive and go to `https://liuxmint.com` (perhaps not in that order).  If you're on ChromeOS, then get a computer.  What you have right now is an oversize foldable phone that can't make calls.

### Image versions

The "latest version" (which really means whatever somebody happens to have uploaded most recently) of the images will always have tags `cpu`, `cpu-dev`, `cuda`, and `cuda-dev`.

Specific release images, in case you want something stable, will have tags like `cpu-0.0.1`, `cuda-dev-0.0.1`, etc.  Browse either `hub.docker.com` or `registry.nersc.org` to see what versions are available.  Ideally, the specific-version images will correspond to the same tag in this github archive.

### On your local machine with Docker

The latest version of the images that Rob has pushed can be found here:

* `docker.io/rknop/roman-snpit-env:cpu`
* `docker.io/rknop/roman-snpit-env:cpu-dev`
* `docker.io/rknop/roman-snpit-env:cuda`
* `docker.io/rknop/roman-snpit-env:cuda-dev`

Get the image on your local machine with `docker pull <imagename>`.  You can then run it with Docker as usual.

#### Running the Cuda image.

Docker and Cuda are always complicated and fraught.  If you're not running Cuda 12.4 on your local machine, there may be problems.  More seriously, if you aren't on x86 Linux (i.e. if you're on a Mac, on ARM Linux, or, heaven forbid, an ARM Mac), it's possible it won't work at all.  In this case, you may need to rebuild the image yourself rather than use Rob's pushed image.

Even then, however, things are complicated, because Cuda libraries inside the container need to talk to the Cuda environment outside the container.  On Perlmutter with podman, this is solved by injecting some libraries into the container so things match up.  If things don't work as is on your local machine, then **ROB FIGURE THIS OUT AND DOCUMENT IT.**

### On perlmutter

On perlmutter, you use the images with `podman-hpc`.  Podman is a container environment that feels much like Docker, and Podman-HPC is NERSC's version of Podman that tries to set things up so you don't need the kind of root access that you usually need in order to run Docker (even if it's only implicit and you never realize it).

#### Images

The latest version of the images that Rob has pushed can be found here:

* `registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu`
* `registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu-dev`
* `registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda`
* `registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev`

There may also be versions of the images with things like `-v0.0.1` appended to the end of the image, which you can use if you want a stable image and don't want to always be repulling the latest.  However, your code will eventually need to run with the same image that every other code does, so you're strongly recommended to work with the latest images.

#### Making the image available to you

First, you need to make sure to log in to the nersc registry.  (It's possible that if you've done this before, you won't need to again, as a file may have been saved in your home directory caching your credentials.  If you skip this step, and get an authentication error on the next step, come back and do this step.)
```
podman-hpc login registry.nersc.gov
```
It will prompt you for your username and password.  Use your regular nersc username and password; just use the password, do *not* append a OTP number the way you do when logging into a node.

Once you're authenticated on the registry, actually pull the image on any node with the following command:
```
podman-hpc pull <imagename>
```
**Important:** do *not* run `podman-hpc image pull...`  That will apper to work, but doesn't do everything necessary, and you will almost certainly later become confused.  (Rob lost at least a day to this a while back.)

Once you've pulled the image, run
```
podman-hpc images
```
to verify that it's there.  If you've just pulled it, you should see the image listed *twice*.  Notice that the right-most column is "R/O"; this means "readonly".  When you pull an image with podman-hpc, it saves a image that is accessible only to the current node where you're running (that one has R/O `false`), but also saves one that will work on any perlmutter node (including compute nodes) (that one has R/O `true`).  Make sure the R/O `true` image is there.

If you log into another login node, or into a compute node, and run `podman-hpc images`, you will *only* see the R/O `true` image.  This is fine; this is the one you need.

You don't need to pull the image every time.  Only pull it if you don't have it yet, or if you want to update it with a newer versions that's been saved to the repository.

#### Actually running

You can run the image with
```
podman-hpc run -it registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu /bin/bash
```
that will start up a shell session running the CPU runtime image.  You can substitute other commands in place of `/bin/bash`; this is what you would do to write a slurm script.  (In that case, remove the `-it` from the command; those flags mean "interactive" and "terminal", and are what you need for a shell session.)   Almost certainly, however, you're going to need other arguments, in particular, `--mount` arguments that make the directories you want to read and write accessible inside the container.

For the GPU, it's a little more complicated.  NERSC has it set up to inject some Cuda libraries into podman containers so they will play nice with the Cuda libraries on the host system.  However, by default, the docker container will not see these injected libraries, so you have to do some things to make it work.  First, though, make sure you're running the right version of the cuda toolkit on perlmutter.  Run
```
module list
```
In the list of modules, you should see `cudatoolkit/12.4`.  If you don't see that, then do
```
module load cudatoolkit/12.4
```
If you see a different version of `cudatoolkit`, then you need to unload that different version and load version 12.4.

To run a container using the `cuda` or `cuda-dev` image, you need a couple of additional arguments to `podman-hpc` so that it will have access to the GPUs, and so that it will see the right libraries:
```
podman-hpc run \
  --gpu \
  --env LD_LIBRARY_PATH=/usr/lib64:/usr/lib/x86_64-linux-gnu:/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs \
  (...)
  registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev \
  <command>
```
(where, for an interactive shell session, `(...)` would include `-it` in addition to any needed mounts and other env vars you set, and `<command>` would be `/bin/bash`).

For an example of using this Docker image, [phrosty example](https://github.com/Roman-Supernova-PIT/phrosty/tree/main/examples/perlmutter).


### On other HPC systems with apptainer

TODO

---

## Building the Docker image

Hopefully you don't need to do this; see above.  If you do, read on.

ROB WRITE MORE -- you can find some build instructions in the `Dockerfile` itself.

**One thing to look out for**: later, pip may install all the nvidia libraries itself!  You may need to do fancy things to get cuda-aware pip packages to use already-installed nvidia libraries.
