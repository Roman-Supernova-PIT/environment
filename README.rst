.. contents::
   :depth: 4

=======================
Roman SN Pit Enviroment
=======================

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

.. _environment-on-nersc:

On NERSC
--------

See above re: the recommendation that you move towards a containerized environment.

Native on NERSC
^^^^^^^^^^^^^^^

**Note:** If you run this way, you can get things going pretty quickly.  However, with the default setup, you will not be able to ``pip install -e`` your own software, because you're using a shared environment.  (We don't want you changing the environment for other people.)  You can always just run your own stuff, and you can try adding directories to your ``PYTHONPATH`` to get your own libraries in, if you're able to work that way.  It *is* possible to set up your own copy of the native NERSC environment; if there is enough demand, we will document that.  However, we strongly recommend instead that you move towards using a `containerized <containerized-nersc>`_ environment.

Make sure that you have set up the `secrets and temp directories <directory-setup>`_.  For the default config of that environment, the file in the secrets directory with the database password is, as of this writing::

  roman_snpit_ou2024_nov_ou2024nov

If you are going to use a different `config file <config-files>`_, you will of course have a different password file.

You can start up the dev environment (the only one that currently exists) on NERSC with::

  source /global/cfs/cdirs/m4358/env/setup_roman_snpit.sh

This will by default (as of this writing) set the ``SNPIT_CONFIG`` environment varaible to point to the right config file for the nov2025 development database.  You can of course point to any other config file as appropriate.  See config-files_ above for more information about config files.

.. _containerized-nersc:

Containerized
^^^^^^^^^^^^^

* Make sure you've set up your `secrets and temp directories <directory-setup>`_.

* Make sure you have the right database password in the right file in your ``~/secrets`` directory.  As of this writing, the file you need to create in that directory with the password that Rob can give you is::

    roman_snpit_ou2024_nov_ou2024nov

* You are probably developing something, and want to have that thing accessible you inside the container.   Go to the *parent* directory of the directory you want avilable.  (I.e., go to the directory you were in when you ran ``git clone ...``.)  You can check out multiple different archives here, and put other things (like config files) here, and they'll all be avilable inside the container.

* Start the environment with::

    bash /global/cfs/cdirs/m4385/env/interactive-podman.sh

* Inside the environment do ``cd /home``.  Here, you will find the subdirectories and files you want to work with.

* When you're done, just ``exit``.

**Note**: If you're going to run big things, you probably want to get yourself an interactive compute node rather than just running on a login node.  If you're only running fast things, a login node is fine.

**Note 2**: Every time you restart the container, it's a fresh environment.  Any ``pip install -e .`` (which you may have done in the thing you're developing— e.g. ``snappl`` or something else) will have to be redone.  When you exited the old container, all of that went away.

Example: developing and testing snappl
""""""""""""""""""""""""""""""""""""""

Suppose you're developing and testing snappl, and want to do this on NERSC.

Make sure you've set up your `secrets and temp directories <directory-setup>`_.

Make yourself a working directory in the PIT space if you haven't already::

  cd /global/cfs/cdirs/m4385/users
  mkdir <yourname>
  cd <yourname>

In this directory, pull the ``snappl`` archive::

  git clone git@github.com:Roman-Supernova-PIT/snappl.git

(You might use ``https://github.com/Roman-Supernova-PIT/snappl.git`` instead, depending on how you're set up to use github.)

At this point, do whatever you want to do inside ``snappl``.  Check out a different branch, edit the code, etc.  For now, let's assume you're not doing anything, you just want to run the tests.  To be abe to run the ``snappl`` tests, you also need the ``photometry_test_data`` archive::

  cd /global/cfs/cdirs/m4385/users/<yoruname>
  git clone https://github.com/Roman-Supernova-PIT/photometry_test_data.git

For what you're doing here, you don't actually need to set up a secrets file, becasue the snappl tests take care of that internally.  However, be aware that you won't be able to run *all* of the snappl tests.  Some of the snappl tests depend on a closed-environment webserver and database server being available.  For that, see `The Test Docker Environment <test-docker-environment>`_ (which, alas, as of this writing doesn't work on NERSC).

Now that you're set up, start the environment with::

  bash /global/cfs/cdirs/m4385/env/interactive_podman.sh

That will put you inside the container.  Go to the snappl tests directory with::

  cd /home/snappl/snappl/tests

Try running some snappl tests.  For some fast and basic tests, try::

  pytest -v test_config.py

For something more serious, try::

  pytest -v test_image.py

Try some of the others.  Some will fail because of the missing database and web servers, but lots should succeed.

Running on the queue
^^^^^^^^^^^^^^^^^^^^

TODO


On the Duke Cosmology Cluster
-----------------------------

**Not currently supported, needs to be updated.**

On SMCE
-------

**Not currently supported, needs to be created.**


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

.. _directory-setup:

Secrets and Temp Directories
----------------------------

Some of the pipeline code refers to a temporary directory, and if you're going to connect to a database, you need a secrets file with the database password.

Secrets dir
^^^^^^^^^^^

Make yourself a ``secrets`` directory under your home directory if you haven't already::

    cd
    mkdir secrets
    chmod 710 secrets
    setfacl -Rdm g::x,o::- secrets

(If the ``setfacl`` command doesn't work, don't worry about it.  What this command is trying to do is set up the directory so that any file you create inside it will *not* be world-readable, which is what you want for a secrets directory.  You can always just make sure that's true manually.)

In this directory, you will need to create text files, each with one line that has the password for relevant database.  The names of those text files depend on which config file you're using.  Some of these names are documented below, but in general you can look at the value of ``system.db.passwordfile`` in the config file to figure out what it's supposed to be.

Temp dir
^^^^^^^^

Make yourself a temp directory somewhere that has a lot of space.  Ideally, this is a directory that's not used for anything else; that way, you know that it's safe at any time to delete anything in here.  (Well, almost any time; if you're right in the middle of running a process that uses this directory, you will probably screw that process up.)

**On NERSC** this temp directory *must* be ``$SCRATCH/snpit_temp`` (unless you want to edit the provided config files).

.. _config-files:

Config Files
------------

To connect to the database, and indeed to do a lot of things with ``snappl`` and some other snpit packages, you need to have a proper config file.  Ideally, the environment you started already points at a default one and you won't have to think about it.  In case you do, read on.

The docker images do *not* have standard config files baked into them.  (Sort of; they actually do, buit it's specifically for running tests.)  The reason for this is that the config file points to a database server, and as we're under development, at different times different people are going to want to point to different database.  As such, whether you're running natively or in a docker image, you're going to have to secure a proper config file for the snpit environment.  Ideally, Rob or somebody will have provided one for you.  The standard procedure for running in a dockerized environment on NERSC (described above) does include a standard config file.


Standard Config Files
^^^^^^^^^^^^^^^^^^^^^

In this directory, you can find some standard configuration files that will point to some dev databases that are available.

For the Nov 2024 database
"""""""""""""""""""""""""

This is the database that we used for the November 2024 hackathon, some are still using it for development.

Make sure you've set up the `secrets and temp directories <directory-setup>`_.  The file in your secrets directory in which you should put the password for the database must be named::

  roman_snpit_ou2024_nov_ou2024nov

If you're not on NERSC, make yourself a directory to store files "in" the database.  On NERSC, these are all under ``/pscratch/sd/m/masao/roman_snpit/database_dirs``; when running on NERSC, you don't have to do anything.  If you are running somewhere else, you will need to do two things.  First, any files you will want to read, you will need to copy from NERSC to the equivalent place on your system. Second, if you write any files, you will need to make sure to sync them up to NERSC.  For this reason, you will probably find it easier to just work at NERSC.

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


----

.. _test-docker-environment:

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

The native environment
^^^^^^^^^^^^^^^^^^^^^^

**Note**: currently only Rob can do this.  Reason: so that people don't accidentally install stuff to the environment, thereby messing it up for everybody else, the directories with the environment are not group-writeable.

The dev environment on NERSC (the only one that currently exists) is defined under ``/global/cfs/cdirs/m4385/env/snpit-env-dev``.  To update the packages in it, first start up the environment with::

  source /global/cfs/cdirs/m4385/env/setup_roman_snpit.sh

Next, go to the checkout of the ``environment`` repo::

  cd /global/cfs/cdirs/m4385/env/environment

Make sure that you have the correct branch checked out, and do a ``git pull -a --no-rebase`` to make sure that branch is up to date.  (Really, make sure you know what you're doing.)  Update the conda environment with::

  conda env update --file sn_pit_dev.yaml

The containers
^^^^^^^^^^^^^^

Read the `docker subdirectory README <https://github.com/Roman-Supernova-PIT/environment/tree/main/docker>`_ for information on updating the docker files.  Once a new dockerfile is updated and pushed to ``registry.nersc.gov``, then run::

  podman-hpc --squash-dir /global/cfs/cdirs/m4385/podman_images pull registry.nersc.gov/m4385/roman-snpit-env:cpu
  podman-hpc --squash-dir /global/cfs/cdirs/m4385/podman_images pull registry.nersc.gov/m4385/roman-snpit-env:cpu-dev
  podman-hpc --squash-dir /global/cfs/cdirs/m4385/podman_images pull registry.nersc.gov/m4385/roman-snpit-env:cuda
  podman-hpc --squash-dir /global/cfs/cdirs/m4385/podman_images pull registry.nersc.gov/m4385/roman-snpit-env:cuda-dev

That will update the docker image used by ``/global/cfs/cdirs/m4385/env/interactive-podman.sh``.


Maintenance on SMCE
-------------------

TODO
