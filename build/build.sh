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

# The name of the triggering repository
export TRIGGERING_REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)
# The name of the Portworx Enterprise repository
export PX_ENTERPRISE_REPO_NAME="pxdocs"
# The name of the PX-Backup repository
export PX_BACKUP_REPO_NAME="pxdocs-backup"
# The name of the PX-Central repository
export PX_CENTRAL_REPO_NAME="pxdocs-central"
# The name of the PX-Enterprsie section
export PX_ENTERPRISE_SECTION_NAME="PX-Enterprise"
# The name of the PX-Enterprsie section
export PX_BACKUP_SECTION_NAME="PX-Backup"
# The name of the PX-Central section
export PX_CENTRAL_SECTION_NAME="PX-Central"

# The following environment variables are set based on the triggering repository
if [ "${TRIGGERING_REPO_NAME}" '==' "${PX_ENTERPRISE_REPO_NAME}" ]; then
  export YAML_SECTION_NAME=$PX_ENTERPRISE_SECTION_NAME
fi
if [ "${TRIGGERING_REPO_NAME}" '==' "${PX_ENTERPRISE_REPO_NAME}" ]; then
  export YAML_SECTION_NAME=$PX_ENTERPRISE_SECTION_NAME
fi

if [ "${TRIGGERING_REPO_NAME}" '==' "${PX_BACKUP_REPO_NAME}" ]; then
  export YAML_SECTION_NAME=$PX_BACKUP_SECTION_NAME
fi
if [ "${TRIGGERING_REPO_NAME}" '==' "${PX_CENTRAL_REPO_NAME}" ]; then
  export YAML_SECTION_NAME=$PX_CENTRAL_SECTION_NAME
fi

# A comma-separated list of branches and versions for which we build the deployment image, update the Algolia index and push the image to GCP
export BRANCH_VERSION_CONFIG=$(yq e ".$YAML_SECTION_NAME.BRANCH_VERSION_CONFIG" ./themes/pxdocs-tooling/build/products.yaml)
# The latest version. We use this variable in the `export-product-url.sh` script to determine whether the version should be added or not to the URLs that we upload to Algolia.
export LATEST_VERSION=$(yq e ".$YAML_SECTION_NAME.LATEST_VERSION" ./themes/pxdocs-tooling/build/products.yaml)
# The name of the product.
export PRODUCT_NAME=$(yq e ".$YAML_SECTION_NAME.PRODUCT_NAME" ./themes/pxdocs-tooling/build/products.yaml)
# We use this environment variable to determine the name of the Algolia index
export PRODUCT_INDEX_NAME=$(yq e ".$YAML_SECTION_NAME.PRODUCT_INDEX_NAME" ./themes/pxdocs-tooling/build/products.yaml)
# The base URL
export VERSIONS_BASE_URL=$(yq e ".$YAML_SECTION_NAME.VERSIONS_BASE_URL" ./themes/pxdocs-tooling/build/products.yaml)
# A comma-separated list of other product names and indices, in the form of`<product-name>=<product-index>`.
export OTHER_PRODUCT_NAMES_AND_INDICES=$(yq e ".$YAML_SECTION_NAME.OTHER_PRODUCT_NAMES_AND_INDICES" ./themes/pxdocs-tooling/build/products.yaml)
# Each product has its own list of redirects. For each product, we use the `VERSIONS_BASE_URL` environment variable to determine the name of the file where the redirects are stored, and then we save that name in the `NGINX_REDIRECTS_FILE` environment variable
export NGINX_REDIRECTS_FILE=$(yq e ".$YAML_SECTION_NAME.NGINX_REDIRECTS_FILE" ./themes/pxdocs-tooling/build/products.yaml)
# The directory where the PX Enterprise manifests are placed
export MANIFESTS_DIRECTORY=$(yq e ".$YAML_SECTION_NAME.MANIFESTS_DIRECTORY" ./themes/pxdocs-tooling/build/products.yaml)
export MANIFESTS_STAGING_DIRECTORY=$(yq e ".$YAML_SECTION_NAME.MANIFESTS_STAGING_DIRECTORY" ./themes/pxdocs-tooling/build/products.yaml)
export BUILDER_IMAGE_PREFIX=$(yq e ".$YAML_SECTION_NAME.BUILDER_IMAGE_PREFIX" ./themes/pxdocs-tooling/build/products.yaml)
export SEARCH_INDEX_IMAGE_PREFIX=$(yq e ".$YAML_SECTION_NAME.SEARCH_INDEX_IMAGE_PREFIX" ./themes/pxdocs-tooling/build/products.yaml)
export DEPLOYMENT_IMAGE_PREFIX=$(yq e ".$YAML_SECTION_NAME.DEPLOYMENT_IMAGE_PREFIX" ./themes/pxdocs-tooling/build/products.yaml)


# The following environment variables are **not** set based on the triggering repository
export ALGOLIA_API_KEY=64ecbeea31e6025386637d89711e31f3
export ALGOLIA_APP_ID=EWKZLLNQ9L

export GCP_CLUSTER_ID=production-app-cluster
export GCP_PROJECT_ID=production-apps-210001
export GCP_ZONE=us-west1-b

export GCP_STAGING_CLUSTER_ID=pxdocs-staging
export GCP_STAGING_PROJECT_ID=portworx-eng
export GCP_STAGING_ZONE=us-central1-c

# Docker builds cannot use uppercase characters in the image name
export LOWER_CASE_BRANCH=$(echo -n $TRAVIS_BRANCH | awk '{print tolower($0)}')

# Set the env vars to the staging values
if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
  export GCP_PROJECT_ID=$GCP_STAGING_PROJECT_ID
  export GCP_CLUSTER_ID=$GCP_STAGING_CLUSTER_ID
  export GCP_ZONE=$GCP_STAGING_ZONE
  export GCLOUD_SERVICE_ACCOUNT_TOKEN=$STAGING_GCLOUD_SVC_TOKEN
fi

echo "Print env variables"
echo $TRAVIS_PULL_REQUEST
echo $GCP_PROJECT_ID
echo $GCP_CLUSTER_ID
echo $GCP_ZONE
echo $GCLOUD_SERVICE_ACCOUNT_TOKEN


export DEPLOYMENT_IMAGE="gcr.io/$GCP_PROJECT_ID/$DEPLOYMENT_IMAGE_PREFIX-$LOWER_CASE_BRANCH:$TRAVIS_COMMIT"
# The current version
export VERSIONS_CURRENT=$(bash themes/pxdocs-tooling/deploy/scripts/versions.sh get-current-branch-version)
# A comma-separated list of all versions. We use this variable to build the version selector.
export VERSIONS_ALL=$(bash themes/pxdocs-tooling/deploy/scripts/versions.sh get-all-versions)
export VERSIONS_TAG=$(echo -n "$VERSIONS_CURRENT" | sed 's/\./-/g')
export ALGOLIA_INDEX_NAME="${PRODUCT_INDEX_NAME}-${VERSIONS_TAG}"
# A comma-separated list of all product names and indices, in the form of `<product-name>=<product-index>`.
export PRODUCT_NAMES_AND_INDICES="${PRODUCT_NAME}=${PRODUCT_INDEX_NAME}-${TRAVIS_BRANCH/./-},${OTHER_PRODUCT_NAMES_AND_INDICES}"
# Build images
travis_retry make image -f ./themes/pxdocs-tooling/build/Makefile
# Publish site -> public
make publish-docker -f ./themes/pxdocs-tooling/build/Makefile
# Build the deployment image
travis_retry make deployment-image -f ./themes/pxdocs-tooling/build/Makefile
travis_retry make check-links -f ./themes/pxdocs-tooling/build/Makefile
# If this is a pull request then we don't want to update algolia index, but we deploy the PR image to the staging server
if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
  bash themes/pxdocs-tooling/deploy/scripts/ci_connect.sh "staging"
  # Push the image to gcr
  echo "Pushing image $DEPLOYMENT_IMAGE"
  gcloud docker -- push $DEPLOYMENT_IMAGE
  echo "Deploying image $DEPLOYMENT_IMAGE to staging server"
  cat "${MANIFESTS_STAGING_DIRECTORY}deployment.yaml" | envsubst
  cat "${MANIFESTS_STAGING_DIRECTORY}deployment.yaml" | envsubst | kubectl apply -f -
  cat "${MANIFESTS_STAGING_DIRECTORY}service-template.yaml" | envsubst
  cat "${MANIFESTS_STAGING_DIRECTORY}service-template.yaml" | envsubst | kubectl apply -f -
fi
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
