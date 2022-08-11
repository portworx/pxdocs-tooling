#!/bin/bash

# update gcloud apt source
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# install docker-ce and kubectl
sudo apt-get update -yq
sudo apt-get -o Dpkg::Options::="--force-confnew" install -yq docker-ce kubectl

# log in to Docker if this isn't a PR
if [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
  echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USER}" --password-stdin
fi

# try to pull from porx

if [ -z "$GH_BOT_TOKEN" ] ; then
    echo "You must first get a personal token from github: https://github.com/settings/tokens"
    echo "Then save your personal token in an env var: export GITHUB_PERSONAL_TOKEN=ghp_..."
    exit 1
fi

# Just pulling this from build.sh for now. We probably want to pull data before the main build script runs.
export PX_VERSION=$(yq e ".$YAML_SECTION_NAME.LATEST_VERSION" ./themes/pxdocs-tooling/build/products.yaml)

# PX BRANCH
branch=gs-rel-${PX_VERSION}

# Get version from the code
curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/vendor/github.com/libopenstorage/openstorage/api/server/sdk/api/api.swagger.json\
		--output api.swagger.json --silent
ver=$(cat api.swagger.json | jq -r '.info.version')
echo "Px version v${PX_VERSION} on branch ${branch} uses the SDK version v${ver}"