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
