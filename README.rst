.. toctree::
   :maxdepth 3

=======================
Roman SN Pit Enviroment
=======================

Provides a conda environment (in ``sn_pit_dev.yaml``) and a docker environment (defined in ``docker/Dockerfile``).

For more information about the Docker images, see the README in the ``docker`` directory.

Environment Varieties
=====================

Production vs. Development
---------------------------

At the moment, as things are evolving quickly, there is *only* a development environment.  At some point there may be a production environment.

Containerized vs. Native
------------------------

The primary supported version of the PIT environment is in a docker container.  This can be run on your local machine with ``docker`` or ``podman`` (*note*: as of this writing, we do not yet support the ARM architecture, which means it won't work on a Mac; you need an ``x86_64`` linux machine).  It can be run on NERSC with ``podman-hpc``.  You *might* be able to run it on other HPC centers with ``apptainer``.

There is also a conda environment (which we call running "natively" on the machine, as opposed to running in a container), which is supported at least at NERSC.  It may not be fully functional.

We recommend you get your code working in a containerized environment, because this is how we're almost certainly going to need to do things in production.  If you can use the standard PIT container (defined here), that's best, but if you require a custom containerized environment, we *might* be able to work with that.  If


Using the Environment
=====================

On your local machine
---------------------

TODO

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

The Test Docker Environment
===========================


Maintaining the Environment
===========================

Building new docker images
--------------------------

TODO

Setting up a conda environment
-------------------------------

TODO

Maintenance on NERSC
--------------------

TODO

Maintenance on SMCE
-------------------

TODO
