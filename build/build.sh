#!/bin/bash

# The travis_retry function  is not available is subshells/commands. See this tweet for details https://twitter.com/travisci/status/499195739353153539?s=20
travis_retry() {
  local result=0
  local count=1
  while [[ "${count}" -le 3 ]]; do
    [[ "${result}" -ne 0 ]] && {
      echo -e "\\n${ANSI_RED}The command \"${*}\" failed. Retrying, ${count} of 3.${ANSI_RESET}\\n" >&2
    }
    # run the command in a way that doesn't disable setting `errexit`
    "${@}"
    result="${?}"
    if [[ $result -eq 0 ]]; then break; fi
    count="$((count + 1))"
    sleep 1
  done

  [[ "${count}" -gt 3 ]] && {
    echo -e "\\n${ANSI_RED}The command \"${*}\" failed 3 times.${ANSI_RESET}\\n" >&2
  }

  return "${result}"
}

# The -e flag makes the build fail if there are any errors
# The -v flag makes the shell print all lines before executing them
set -ev

# Build images
travis_retry make image -f ./themes/pxdocs-tooling/build/Makefile
# Publish site -> public
make publish-docker -f ./themes/pxdocs-tooling/build/Makefile
# Build the deployment image
travis_retry make deployment-image -f ./themes/pxdocs-tooling/build/Makefile
travis_retry make check-links -f ./themes/pxdocs-tooling/build/Makefile
# If this is a pull request then we don't want to update algolia or deploy
if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then exit 0; fi
# this checks if the current branch is present in the BRANCH_VERSION_CONFIG variable if exists if not
if [ "${TRAVIS_PULL_REQUEST}" == "false" ] && [ "$(bash themes/pxdocs-tooling/deploy/scripts/versions.sh should-build-current-branch)" != "yes" ]; then exit 0; fi
# Update the Algolia index
travis_retry make search-index-image -f ./themes/pxdocs-tooling/build/Makefile
travis_retry make search-index-docker -f ./themes/pxdocs-tooling/build/Makefile
# Connect the GCLOUD_SERVICE_ACCOUNT_TOKEN, GCP_PROJECT_ID, GCP_ZONE and GCP_CLUSTER_ID vars -> gcloud and kubectl
bash themes/pxdocs-tooling/deploy/scripts/ci_connect.sh
# Push the image to gcr
echo "Pushing image $DEPLOYMENT_IMAGE"
gcloud docker -- push $DEPLOYMENT_IMAGE
echo "Deploying image $DEPLOYMENT_IMAGE"
cat "${MANIFESTS_DIRECTORY}deployment.yaml" | envsubst
cat "${MANIFESTS_DIRECTORY}deployment.yaml" | envsubst | kubectl apply -f -
cat "${MANIFESTS_DIRECTORY}service-template.yaml" | envsubst
cat "${MANIFESTS_DIRECTORY}service-template.yaml" | envsubst | kubectl apply -f -
