.. contents::
   :depth: 4

=======================
Roman SN Pit Enviroment
=======================

Provides a conda environment (in ``sn_pit_dev.yaml``) and a docker environment (defined in ``docker/Dockerfile``).

For more information about the Docker images (including building them and publishing them for the PIT as a whole), see the README in the ``docker`` directory.

----

Environment Varieties
=====================

Production vs. Development
--------------------------

At the moment, as things are evolving quickly, there is *only* a development environment.  At some point there may be a production environment.

Containerized vs. Native
------------------------

The primary supported version of the PIT environment is in a docker container.  This can be run on your local machine with ``docker`` or ``podman``.  (*Note*: as of this writing, we do not yet support the ARM architecture, which means it won't work on a Mac; you need an ``x86_64`` linux machine.)  It can be run on NERSC with ``podman-hpc``.  You *might* be able to run it on other HPC centers with ``apptainer``, if you know what you're doing.

There is also a conda environment (which we call running "natively" on the machine, as opposed to running in a container), which is supported at least at NERSC.  It may not be fully functional.

We recommend you get your code working in a containerized environment, because this is how we're almost certainly going to need to do things in production.  If you can use the standard PIT container (defined here), that's best, but if you require a custom containerized environment, we *might* be able to work with that.  If

----

Using the Environment
=====================

.. _config-files:

Config Files
------------

**If you're on NERSC**: You *may* be able to skip this section.  See environment-on-nersc_.

The docker images do *not* have standard config files baked into them.  (Sort of; they actually do, buit it's specifically for running tests.)  The reason for this is that the config file points to a database server, and as we're under development, at different times different people are going to want to point to different database.

As such, whether you're running natively or in a docker image, you're going to have to secure a proper config file for the snpit environment.  Ideally, Rob or somebody will have provided one for you.  See environment-on-nersc_ below if you're running in NERSC.

Standard Config Files
^^^^^^^^^^^^^^^^^^^^^

In this directory, you can find some standard configuration files that will point to some dev databases that are available.

For the Nov 2024 database
"""""""""""""""""""""""""

This is the database that we used for the November 2024 hackathon, some are still using it for development.

For these config files, you must do a few things first to get yourself set up:

* Make yourself a ``secrets`` directory under your home directory if you haven't already::

    cd
    mkdir secrets
    chmod 710 secrets
    setfacl -Rdm g::x,o::- secrets

  (If the ``setfacl`` command doesn't work, don't worry about it.  What this command is trying to do is set up the directory so that any file you create inside it will *not* be world-readable, which is what you want for a secrets directory.  You can always just make sure that's true manually.)

* Next, edit the file ``secrets/roman_snpit_ou2024_nov_ou2024nov`` and make it have one line that has the password you were given for this datbase.  (This password is not here because we do *not* want to commit it to a git archive!)

* Make yourself a temp directory.  This needs to have a decent amount of space.  Ideally, make it a new directory, because if you're not storing anything else here, it's always safe to just delete anything that gets left behind here.

  * **On NERSC**: this directory *must* be ``$SCRATCH/snpit_temp`` (unless you want to edit the config file)

* If you're not on NERSC, make yourself a directory to store files "in" the database.  On NERSC, these are all under ``/pscratch/sd/m/masao/roman_snpit/database_dirs``; when running on NERSC, you don't have to do anything.  If you are running somewhere else, you will need to do two things.  First, any files you will want to read, you will need to copy from NERSC to the equivalent place on your system. Second, if you write any files, you will need to make sure to sync them up to NERSC.  For this reason, you will probably find it easier to just work at NERSC.

The config files, found in the same directory as this README file, are:

* ``nov2025_container_config.yaml`` : This is a config file you'd use when running in a container folowing the procedure in (TODO).
* ``nov2025_nersc_native_config.yaml`` : This config file will work if you're running on NERSC.  If you want to try to run somewhere else, you will need to edit this file, and replace ``system.paths.temp_dir`` and ``system.paths.data_dir`` with the right values for your system.


Your own modifications to standard config files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The provided config files have enough config information to connect you to the database and (ideally) to point at the place where all the files are stored.  However, you may need to change this.  This could be because you want to point to a custom database, because you have copies of files on your own system somewhere different from what the proivded config file assumes, or because you want to configure something differently from how it's configured in the provided file.  Most likely, you are developing something that has its own config, so you need to add all those config values to the standard config file.

Rather than modifying a provided file, we strongly recommend just leaving the provided as is.  (This way, if things change, you can just replace it, rather than having to figure out how to merge the new changes with your edits.)  Then, make your own config file, and start it with::

  replaceable_preloads:
    - /path/to/provided/config/file.yaml

Then, in the rest of that config file, add *only* what you need.  You do *not* need to copy anything from the provided file (e.g. database settings or what-not); the ``replaceable_preloads`` thingy means that that other config file will be read first, and then what's in your config file will be added to or replace what's there.  Usually, you would then add only the config values for your own code that you're working on.

To figure out what ``/path/to/provided/config/file.yaml`` should be replaced with:

* If you downloaded a config file and put it somewhere, just put in the path to where you downloaded it.

* If you're running a provided environment (e.g. on NERSC), just start up that environment and look at the current value of ``$SNPIT_CONFIG``.  That will tell you where the standard config file is.

To use your config file, set the environment variable ``SNPIT_CONFIG`` to point at the new config file that you've created.


On your local machine
---------------------

Native
^^^^^^

An envioronment that is native for your system is not currently supported.  However, you may be able to get enough to do what you need by just doing::

  pip install roman-spnit-snappl

As of this writing, snappl is updated pretty frequently, so you'll want to regularly do::

  pip install --upgrade roman-snpit-snappl

Then, make sure you get a `config file <config-files>`_ that points to the right database.


Containerized
^^^^^^^^^^^^^

TODO

.. _environment-on-nersc:

On NERSC
--------

See above re: the recommendation that you move towards a containerized environment.

Native on NERSC
^^^^^^^^^^^^^^^

Containerized
^^^^^^^^^^^^^

TODO

On the Duke Cosmology Cluster
-----------------------------

**Not currently supported, needs to be updated.**

On SMCE
-------

**Not currently supported, needs to be created.**

----

The Test Docker Environment
===========================

TODO

----

Maintaining the Environment
===========================

The two most important files to maintain are ``requirements-cpu.txt`` and ``requirements-cuda.txt``, as these list all the pip-installed packages that are used in both the native and docker environments.  Of course, things that require Cuda should go in ``requirements-cuda.txt``; everything else should go in ``requirements-cpu.txt``.  (Do not put anything in both; the ``-cuda.txt`` requirements are added to what's in the cpu file.)  Most of the things in these files are standard external libraries.  If you add new ones, make sure to pin the version of the library you're adding.  As of this writing, the only PIT-specific things in these files are ``roman-snpit-snappl`` (in the CPU file) and ``sfft-romansnpit`` (in the Cuda file).  Make sure that those are bumped to the right versions.  In the future, as parts of the pipeline stabilize, we will incorporate more PIT code into the environment.

Building new docker images
--------------------------

See the ``README.rst`` file in the ``docker`` subdirectory.

Setting up a conda environment
------------------------------

TODO

Maintenance on NERSC
--------------------

TODO

Maintenance on SMCE
-------------------

TODO
