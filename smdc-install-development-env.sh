## Install a development environment suitable for Roman SNPIT tools on SMDC
# Currently targeted at photometry packages: sidecar, phrosty, campari
#
# This script only needs to be run once to set up the environment, and then you can activate it with
# source snpit-photometry/bin/activate
#
# In brief, this install script:
#
# 1. Loads spack into env
# 2. spack load miniconda3
# 3. Create Python venv
# 4. pip install Roman SN PIT code into this venv

# https://spack-tutorial.readthedocs.io/en/latest/tutorial_environments.html
source /shared/spack/share/spack/setup-env.sh

# Get our Python environment
# Miniconda will start us out with a reasonable one.
spack load miniconda3

# Append conda initialization into our SHELL startup, e.g., ~/.bashrc
conda init

# Start a new terminal to get conda
# 
# You can also resources your SHELL init script (here ~/.bashrc)
# but it is more advisable to open a new terminal
# whenever a file that's run on shell startup is changed so that you can 
# still access the file to edit it if something goes wrong.
source ~/.bashrc

# Now we can just create our Python env from the Python that is available in the miniconda3 spack module
# We don't need to actually conda install anything.

# cd to wherever you want the venv directory to live
mkdir -p ${HOME}/snpit
cd ${HOME}/snpit
python -m venv snpit-photometry

# Now activate the Python venv
# You will run this command whenever you want to activate your development environment
source snpit-photometry/bin/activate

# Doesn't matter, but pip is updated frequently and whenever you run pip
# it will bug you to update it, so we can do that once to avoid those pestering messages for a little bit.
pip install --upgrade pip

# First time this will take ~10 minute as it installs all the dependencies of roman-snpit-snappl]
pip install roman-snpit-snappl

# You have to separately install roman_imsim because it is not in PyPi
# and thus we can't make it a dependency of snappl
# because PyPi wouldn't accept dependencies to non-published packages
pip install git+https://github.com/matroxel/roman_imsim.git@21ea15a

# If you want cupy, you have to explicitly install it
# because it's not a dependency of our photometry codes, 
# which can be run under either numpy or cupy
# You need to be on a GPU machine to install cupy
# We currently (2026-08-11) use cupy-cuda12x for the GPU machines at SMDC
# pip install cupy-cuda12x

# Some of the package specify a towncrier dependency, some don't
# Since you are likely setting up a development environment here go ahead and
# install things that will be needed or useful in development
# Used in the dev workflow
pip install pytest
pip install ruff
pip install towncrier
