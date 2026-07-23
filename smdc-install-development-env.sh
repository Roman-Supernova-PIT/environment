# 2026-07-18, Michael Wood-Vasey, following up on suggestion from Ben Rose
#
# Install a development environment suitable for Roman SNPIT tools on SMDC
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

# Created an ~/.bashrc.spack file and first time have to reload ~/.bashrc
source ~/.bashrc.spack

# Now we can just create our Python env from the Python that is available in the miniconda3 spack module
# We don't need to actually conda install anything.

# cd to whever you want the ven directory to live
python -m venv create snpit-photometry
source snpit-photometry/bin/activate

# Doesn't matter, but will get ride of update pesters
pip install --upgrade pip

# First time this will take ~10 minutes.
pip install roman-snpit-snappl

