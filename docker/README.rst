#############################
Docker Image for Roman SN PIT
#############################

.. contents::
   :depth: 2

Overview
========

The files in this directory are intended to be able to build docker images usable by all of the SN PIT.  These images, ideally, should work with ``docker`` on your local machine, with ``podman-hpc`` on perlmutter, with ``apptainer`` on other HPC clusters, and (somehow) on AWS (and probably other cloud providers).  For general information about using the environment, see the `README file in the top level of the environment repo <https://github.com/Roman-Supernova-PIT/environment>`_.

----

Using the Docker images
=======================

Ideally, you will not need to build the docker images yourself, but can use ones already built and pushed by Rob.  Exactly where you use them depends on the machine where you're running.  See the `README file in the top level of the environment repo <https://github.com/Roman-Supernova-PIT/environment>`_ for basic documentation on using the environment.

**Warning:** these images are built on an x86_64 Linux machine.  If you're on an ARM Linux box, on an x86_64 Mac, or, heaven forbid, an ARM Mac, it's possible you will have problems.  (This is especially true with the Cuda images.)  While the obvious solution is to just get an x86_64 Linux desktop or laptop, you may be able to get things to work by just rebuilding the images yourself with docker.  (As of this writing, we have failed to successfully build the docker images under the ARM architecture.  We really want to get this to work.)

If you're on Windows, then your best bet is to reformat your hard drive and go to ``https://liuxmint.com`` (perhaps not in that order).  If you're on ChromeOS, then get a computer.  What you have right now is an oversize foldable phone that can't make calls.

.. _docker-image-versions:

Image versions
--------------

The "latest version" (which really means whatever somebody happens to have uploaded most recently) of the images will always have tags ``cpu``, ``cpu-dev``, ``cuda``, and ``cuda-dev``:

* ``cpu`` : The best general-use image.  Use this if you don't know what you want to use.
* ``cpu-dev`` : Also includes compilers, development libraries, and some debug tools.
* ``cuda`` : Includes ``pycuda`` and the ``cuda`` libraries for GPU access.
* ``cuda-dev`` : Cuda, plus development libraries and compilers.

Specific release images, in case you want something stable, will have tags like ``cpu-0.0.1``, ``cuda-dev-0.0.1``, etc.  Browse either ``hub.docker.com`` or ``registry.nersc.org`` to see what versions are available.  (TODO: describe how to browse what's available in the ``ghcr.io`` image repo.)  Ideally, the specific-version images will correspond to the same tag in this github archive.

Ideally, in production, we will use the non-dev images (i.e. ``cpu`` and ``cuda``), and you should test your code under the those images (which are smaller than the dev images by a few GB).  However, if you want to do any profiling, use the dev images.  If things aren't working with the runtime images, try the dev images, and then talk to Rob about what's necessary to change either in your code, or in the docker images, to make it all work.

(Note that if you're using ``pycuda``, you may be stuck with using the full enormous ``cuda-dev`` image, as it seems not to work with just the ``cuda`` image.  Hopefully at some point Rob will figure out the minimum number of packages to move from the ``cuda-dev`` to the ``cuda`` image to make ``pycuda`` work without having to use the 10GB docker image.)

The latest version of the images that Rob has pushed can be found here:

* ``ghcr.io/roman-supernova-pit/roman-snpit-env:cpu``
* ``ghcr.io/roman-supernova-pit/roman-snpit-env:cpu-dev``
* ``ghcr.io/roman-supernova-pit/roman-snpit-env:cuda``
* ``ghcr.io/roman-supernova-pit/roman-snpit-env:cuda-dev``
* ``registry.nersc.gov/m4385/roman-snpit-env:cpu``
* ``registry.nersc.gov/m4385/roman-snpit-env:cpu-dev``
* ``registry.nersc.gov/m4385/roman-snpit-env:cuda``
* ``registry.nersc.gov/m4385/roman-snpit-env:cuda-dev``
* ``docker.io/rknop/roman-snpit-env:cpu``
* ``docker.io/rknop/roman-snpit-env:cpu-dev``
* ``docker.io/rknop/roman-snpit-env:cuda``
* ``docker.io/rknop/roman-snpit-env:cuda-dev``

We recommend using the ``ghcr.io`` or ``registry.nersc.gov`` images if possible, because anybody (not just Rob) can update them.  However, the ``docker.io/rknop`` images are pubicly available, so are available to you if you're not able to authenticate to ``ghcr.io`` or ``registry.nersc.gov``.


On your local machine with Docker
---------------------------------

Get the image you want on your local machine with ``docker pull <imagename>``.  You can then run it with Docker as usual.  The ``docker.io`` images should be publicly available.  You *might* need to do ``docker login <host>`` to pull the images on the github repository or on NERSC.  If that fails, it probably means you don't have read access to the relevant servers.  Ask the PIT software admins to add you.

For more information, see the `README file in the top level of the environment repo <https://github.com/Roman-Supernova-PIT/environment>`_.  Also, look at the section "The Test Docker Environment" there.



Running the Cuda image
^^^^^^^^^^^^^^^^^^^^^^

Docker and Cuda are always complicated and fraught.  If you're not running Cuda 12.4 on your local machine, there may be problems.  More seriously, if you aren't on x86 Linux, it's possible it won't work at all.  In this case, you may need to rebuild the image yourself rather than use Rob's pushed image.

Even then, however, things are complicated, because Cuda libraries inside the container need to talk to the Cuda environment outside the container.  On Perlmutter with podman, this is solved by injecting some libraries into the container so things match up.  If things don't work as is on your local machine, then **ROB FIGURE THIS OUT AND DOCUMENT IT.**

On perlmutter
-------------

On perlmutter, you use the images with ``podman-hpc``.  Podman is a container environment that feels much like Docker, and Podman-HPC is NERSC's version of Podman that tries to set things up so you don't need the kind of root access that you usually need in order to run Docker (even if it's only implicit and you never realize it).


Making the image available to you
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First, you need to make sure to log in to the nersc registry.  (It's possible that if you've done this before, you won't need to again, as a file may have been saved in your home directory caching your credentials.  If you skip this step, and get an authentication error on the next step, come back and do this step.)::

  podman-hpc login registry.nersc.gov

It will prompt you for your username and password.  Use your regular nersc username and password; just use the password, do *not* append a OTP number the way you do when logging into a node.

Once you're authenticated on the registry, actually pull the image on any node with the following command::

  podman-hpc pull <imagename>

**Important:** do *not* run ``podman-hpc image pull...``  That will apper to work, but doesn't do everything necessary, and you will almost certainly later become confused.  (Rob lost at least a day to this a while back.)

Once you've pulled the image, run::

  podman-hpc images

to verify that it's there.  If you've just pulled it, you should see the image listed *twice*.  Notice that the right-most column is "R/O"; this means "readonly".  When you pull an image with podman-hpc, it saves a image that is accessible only to the current node where you're running (that one has R/O ``false``), but also saves one that will work on any perlmutter node (including compute nodes) (that one has R/O ``true``).  Make sure the R/O ``true`` image is there.

If you log into another login node, or into a compute node, and run ``podman-hpc images``, you will *only* see the R/O ``true`` image.  This is fine; this is the one you need.

You don't need to pull the image every time.  Only pull it if you don't have it yet, or if you want to update it with a newer versions that's been saved to the repository.

Actually running
^^^^^^^^^^^^^^^^

You can run the image with::

  podman-hpc run -it registry.nersc.gov/m4385/rknop/roman-snpit-env:cpu /bin/bash

that will start up a shell session running the CPU runtime image.  You can substitute other commands in place of ``/bin/bash``; this is what you would do to write a slurm script.  (In that case, remove the ``-it`` from the command; those flags mean "interactive" and "terminal", and are what you need for a shell session.)   Almost certainly, however, you're going to need other arguments, in particular, ``--mount`` arguments that make the directories you want to read and write accessible inside the container.

For the GPU, it's a little more complicated.  NERSC has it set up to inject some Cuda libraries into podman containers so they will play nice with the Cuda libraries on the host system.  However, by default, the docker container will not see these injected libraries, so you have to do some things to make it work.  First, though, make sure you're running the right version of the cuda toolkit on perlmutter.  Run::

  module list

In the list of modules, you should see ``cudatoolkit/12.4``.  If you don't see that, then do::

  module load cudatoolkit/12.4

If you see a different version of ``cudatoolkit``, then you need to unload that different version and load version 12.4.

To run a container using the ``cuda`` or ``cuda-dev`` image, you need a couple of additional arguments to ``podman-hpc`` so that it will have access to the GPUs, and so that it will see the right libraries::

  podman-hpc run \
    --gpu \
    --env LD_LIBRARY_PATH=/usr/lib64:/usr/lib/x86_64-linux-gnu:/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs \
    (...)
    registry.nersc.gov/m4385/rknop/roman-snpit-env:cuda-dev \
    <command>

(where, for an interactive shell session, ``(...)`` would include ``-it`` in addition to any needed mounts and other env vars you set, and ``<command>`` would be ``/bin/bash``).

For an example of using this Docker image, see `the phrosty perlmutter example <https://github.com/Roman-Supernova-PIT/phrosty/tree/main/examples/perlmutter>`_.


On other HPC systems with apptainer
-----------------------------------

TODO

----

.. _building-docker-image:

Building the Docker image
=========================

Hopefully you don't need to do this; see above.  If you do, read on.

There is a ``Makefile`` in the top-level directory of the environment github checkout that should let you build images just with::

  make VER=<version> docker-images

where ``<version>`` is the right thing.  If you're just building this locally for your own test or development purposes, it doesn't matter what ``<version>`` is.

If you're making docker images you intend to upload to share with the rest of the PIT, see publishing-docker-image_.

If, for some reason, you want to manually build a docker image individually yourself, look at the comments in ``Dockerfile``.

Pitfalls and Gotchas
--------------------

* You may need the nvidia runtime to build the cuda images.  That is extremely annoying, because as far as I can tell, there's no way to specify that at run time, but you have to change the system default.  This is what Rob has to do on his desktop to make this happen:

    * Make sure you have the nvidia container runtime installed.  (On Debian Linux, you can do this by adding an apt archive to ``/etc/apt/source.list.d`` pointing at ``https://nvidia.github.io/libnvidia-container/stable/deb/$(ARCH)`` where ``$(ARCH)`` is either ``amd64`` or ``arm64`` (I think).  If you're not familiar with how to do this kind of thing, ask Rob for advice.)
    * Edit /etc/docker/daemon.json
    * Add a , just after the last thing inside the outermost ``{}``
    * On the line before the last } (but after the comma you just added), add::

        "default-runtime": "Nvidia"

    * Stop and restart the docker dameon with /etc/init.d/docker restart
    * Remember later after you're done building to undo the damage you just did to your system.

* Pip may install all the nvidia libraries itself!  You may need to do fancy things to get cuda-aware pip packages to use already-installed nvidia libraries.  This will mostly matter if you're updating the image or editing things.  Pay close attention and make usre that the dockerfiles don't come out too much larger than their (already absurd) current nominal sizes, which are (approximately):

     * cpu :       2.59GB
     * cpu-dev :   3.14GB
     * cuda :      6.66GB
     * cuda-dev : 12.2 GB


----

.. _publishing-docker-image:

Publishing a new version of the Docker image for the whole PIT
==============================================================

Read building-docker-image_ for reference (including the pitfalls and gotchas).

If you're going to publish the docker image for everybody, then you need to be a bit more careful.

* Make sure that the docker images are all right and work by building them locally and testing them.  Once you're happy, do the rest of this list.

  * As part of this, make sure that ``requirements-cpu.txt`` is pointing to the right version of ``roman-snpit-snappl``.  Right now, most of the time I (Rob) release new environemnts is because ``snappl`` has been updated.

* First, make sure you're in a fully committed and pushed checkout of the environment git repo, and that you're on the branch you mean to be on.  (``git status`` should show no outstanding changes.)

* Run ``git tag`` to see what earlier versions are there.  They don't sort the way you'd want, alas, so you have to pay attention.  Figure out what the latest version is.  (Make sure you ``git pull -a`` *a lot* in your ``environment`` checkout so you get tags that anybody else has defined!)

* Create a new tag with ``git tag <major>.<minor>.<stepping>``, where *probably* ``<major>`` and ``<minor>`` are the same numbers as the latest existing git tag, and ``<stepping>`` is just incremented by one.  However, you should do `semantic versioning <https://semver.org/>`_ right.

* Push your new tag up to github with ``git push --tag``

* Then make ``<version>`` in the ``make`` command (run from the top level of your checkout of the ``environment`` repo)::

    make VER=<version> docker-images

* Push the docker images with::

    make push-docker-images

  This will only push the images to ``ghcr.io`` and ``registry.nersc.gov``, it will *not* push the images to ``docker.io/rknop``.  The reason for this is that only Rob can push the latter version.  If you are Rob, you can run ``make push-rknop-docker-images`` to also push those.


