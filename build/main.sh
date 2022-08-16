#!/bin/bash

# Not sure where we are here
echo "$PWD"

# This file runs all other shell scripts. It might be a better idea to call these all from travis.
# The most important thing is that these all run within the same process, so env vars are shared.

echo "setting env vars"
source ./themes/pxdocs-tooling/build/set_env_vars.sh

echo "pulling data for automation"
source ./themes/pxdocs-tooling/build/pull_data.sh

echo "running build"
source ./themes/pxdocs-tooling/build/build.sh