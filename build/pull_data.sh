# try to pull from porx


# this will not work if this is a PR, unless I start sharing encrypted env vars with PRs.   
if [ -z "$GH_BOT_TOKEN" ] ; then
    echo "You must first get a personal token from github: https://github.com/settings/tokens"
    echo "Then save your personal token in an env var: export GITHUB_PERSONAL_TOKEN=ghp_..."
    exit 1
fi

# Just pulling this from build.sh for now. We probably want to pull data before the main build script runs. This needs more env vars than I'm pulling here.
# I'm going to bypass this for now.

# export PX_VERSION=$(yq e ".$YAML_SECTION_NAME.LATEST_VERSION" ./themes/pxdocs-tooling/build/products.yaml)
export PX_VERSION=2.12.0

if [ -z "$PX_VERSION" ] ; then
    echo "Missing PX_VERSION env var"
    exit 1
fi

# PX BRANCH
branch=gs-rel-${PX_VERSION}

# Get version from the code
curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/vendor/github.com/libopenstorage/openstorage/api/server/sdk/api/api.swagger.json\
		--output api.swagger.json --silent
ver=$(cat api.swagger.json | jq -r '.info.version')
echo "Px version v${PX_VERSION} on branch ${branch} uses the SDK version v${ver}"