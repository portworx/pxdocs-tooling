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

# Portworx Version
PXVERSION=2.12.0

# PX BRANCH
branch=gs-rel-${PXVERSION}

# Get version from the code
curl https://raw.githubusercontent.com/portworx/porx/${branch}/vendor/github.com/libopenstorage/openstorage/api/server/sdk/api/api.swagger.json\
		--output api.swagger.json --silent
ver=$(cat api.swagger.json | jq -r '.info.version')
echo "Px version v${PXVERSION} on branch ${branch} uses the SDK version v${ver}"