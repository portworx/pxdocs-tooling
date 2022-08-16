#!/bin/bash

# This file runs all other shell scripts. It might be a better idea to call these all from travis.
# The most important thing is that these all run within the same process, so env vars are shared.
source set_env_vars.sh
source pull_data.sh
source build.sh