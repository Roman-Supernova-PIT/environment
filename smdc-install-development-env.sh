# 2026-07-18, Michael Wood-Vasey, following up on suggestion from Ben Rose
#
# Install a development environment suitable for Roman SNPIT tools on SMDC
# Currently targeted at photometry packages: sidecar, phrosty, campari
#
# Notes: Previously container-based instructions for SMDC
# used the apptainer container to get the Python environment
# But we can just use miniconda to do that
#
# 1. Load spack into env
# 2. spack load miniconda3
# 3. Create Pypthon venv
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
# MWV: I actually store these instructions separately in an ~/.bashrc.spack file
# and only source that when I need to.  We won't have to load conda once
# we have our Python venv installed

# cd to whever you want the ven directory to live
python -m venv create snpit-photometry

# Now activate the Python venv
# You will run this command whenever you want to activate your development environment
source snpit-photometry/bin/activate

# Doesn't matter, but pip is updated frequently and whenever you run pip
# it will bug you to update it, so we can do that once to avoid those pestering messages for a little bit.
pip install --upgrade pip

# First time this will take ~10 minutes.
pip install roman-snpit-snappl

# Then if you want to use a particular package sidecar, phrosty, campari
# you can either pip install it from PyPi, if available
# or "pip install -e ." from a local checkout
#
# Yes, the separate pip install roman-snpit-snappl above isn't necessary
# because the dependencies of sidecar, phrosty, campari
# should pull it in anyway, but in my (MWV) brain it makes
# sense to do these as two steps.
# Because this next lines are something one will likely
# be redoing often.
cd campari
pip install -e .

