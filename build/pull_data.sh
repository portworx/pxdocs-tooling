# try to pull from porx

# We need to decide if we only want to run this on upstream builds, or also for PRs. We currently don't export ecypted env vars to PRs, so I'll have this exit. 
if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then 
    echo "not PR, exting"
    exit 0; 
fi

# Ensure that the token is set
if [ -z "$GH_BOT_TOKEN" ] ; then
    echo "You must first get a personal token from github: https://github.com/settings/tokens"
    echo "Then save your personal token in an env var: export GITHUB_PERSONAL_TOKEN=ghp_..."
    exit 1
fi

# This is in build.sh, not sure we want to also have it here. The name of the triggering repository
export TRIGGERING_REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)
# This is in build.sh, not sure we want to also have it here. The name of the Portworx Enterprise repository
export PX_ENTERPRISE_REPO_NAME="pxdocs"

# This is in build.sh, not sure we want to also have it here.
if [ "${TRIGGERING_REPO_NAME}" '==' "${PX_ENTERPRISE_REPO_NAME}" ]; then
  export YAML_SECTION_NAME=$PX_ENTERPRISE_SECTION_NAME
fi

# This is in build.sh, but we use a different variable there. We probably want to pull data before the main build script runs and standardize the var name in this file.
export PX_VERSION=$(yq e ".$YAML_SECTION_NAME.LATEST_VERSION" ./themes/pxdocs-tooling/build/products.yaml)

# Ensure the env var set successfully
if [ -z "$PX_VERSION" ] ; then
    echo "Missing PX_VERSION env var"
    exit 1
fi

# build the Portworx branch string
branch=gs-rel-${PX_VERSION}

# Get version from porx
curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/vendor/github.com/libopenstorage/openstorage/api/server/sdk/api/api.swagger.json\
		--output api.swagger.json --silent
ver=$(cat api.swagger.json | jq -r '.info.version')

# Keep logging this version into Travis, it'll be helpful for debugging if something goes wrong
echo "Px version v${PX_VERSION} on branch ${branch} uses the SDK version v${ver}"

# Write the value into a YAML file under the `/data` folder


# Hugo will pick up the YAML value and render it into the docs using a shortcode


# We should probably shuffle the build scripts around some.
# 1. init env vars in the `before_install.sh` file, or define a new one that inits all env vars that build scripts will use
# 2. run scripts that pull data
# 3. run hugo, etc. 

# Wishlist:
# * an override setting that allows us to run this locally and build a file that can be used to override the automated output. We can put an if statement into
#   the template to pull the override file rather than the generated one if it exists. This would be most useful in other data pull scripts, maybe not here.