#!/bin/bash

# update gcloud apt source
# echo "deb http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# install docker-ce and kubectl
sudo apt-get update -yq
sudo apt-get -o Dpkg::Options::="--force-confnew" install -yq docker-ce
sudo snap install kubectl --channel=1.25 --classic

# log in to Docker if this isn't a PR
if [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
  echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USER}" --password-stdin
fi
