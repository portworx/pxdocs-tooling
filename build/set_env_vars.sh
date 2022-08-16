#!/bin/bash

# The -e flag makes the build fail if there are any errors
# The -v flag makes the shell print all lines before executing them
set -e

# The name of the triggering repository
export TRIGGERING_REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)
# The name of the Portworx Enterprise repository
export PX_ENTERPRISE_REPO_NAME="pxdocs"
# The name of the PX-Backup repository
export PX_BACKUP_REPO_NAME="pxdocs-backup"
# The name of the PX-Central repository
export PX_CENTRAL_REPO_NAME="pxdocs-central"
# The name of the PX-PDS section
export PX_PDS_REPO_NAME="pxdocs-pds"
# The name of the PX-saasbackup section
export PX_SAASBACKUP_REPO_NAME="pxdocs-saasbackup"
# The name of the PX-Enterprsie section
export PX_ENTERPRISE_SECTION_NAME="PX-Enterprise"
# The name of the PX-Backup section
export PX_BACKUP_SECTION_NAME="PX-Backup"
# The name of the PX-Central section
export PX_CENTRAL_SECTION_NAME="PX-Central"
# The name of the PX-PDS section
export PX_PDS_SECTION_NAME="PX-PDS"
# The name of the PX-SAASBACKUP section
export PX_SAASBACKUP_SECTION_NAME="PX-Saasbackup"

# The following environment variables are set based on the triggering repository
if [ "${TRIGGERING_REPO_NAME}" '==' "${PX_ENTERPRISE_REPO_NAME}" ]; then
  export YAML_SECTION_NAME=$PX_ENTERPRISE_SECTION_NAME
fi
if [ "${TRIGGERING_REPO_NAME}" '==' "${PX_BACKUP_REPO_NAME}" ]; then
  export YAML_SECTION_NAME=$PX_BACKUP_SECTION_NAME
fi
if [ "${TRIGGERING_REPO_NAME}" '==' "${PX_CENTRAL_REPO_NAME}" ]; then
  export YAML_SECTION_NAME=$PX_CENTRAL_SECTION_NAME
fi
if [ "${TRIGGERING_REPO_NAME}" '==' "${PX_PDS_REPO_NAME}" ]; then
  export YAML_SECTION_NAME=$PX_PDS_SECTION_NAME
fi
if [ "${TRIGGERING_REPO_NAME}" '==' "${PX_SAASBACKUP_REPO_NAME}" ]; then
  export YAML_SECTION_NAME=$PX_SAASBACKUP_SECTION_NAME
fi

echo "YAML_SECTION_NAME set to: ${YAML_SECTION_NAME}"

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
export BUILDER_IMAGE_PREFIX=$(yq e ".$YAML_SECTION_NAME.BUILDER_IMAGE_PREFIX" ./themes/pxdocs-tooling/build/products.yaml)
export SEARCH_INDEX_IMAGE_PREFIX=$(yq e ".$YAML_SECTION_NAME.SEARCH_INDEX_IMAGE_PREFIX" ./themes/pxdocs-tooling/build/products.yaml)
export DEPLOYMENT_IMAGE_PREFIX=$(yq e ".$YAML_SECTION_NAME.DEPLOYMENT_IMAGE_PREFIX" ./themes/pxdocs-tooling/build/products.yaml)


# The following environment variables are **not** set based on the triggering repository
export ALGOLIA_API_KEY=64ecbeea31e6025386637d89711e31f3
export ALGOLIA_APP_ID=EWKZLLNQ9L
export GCP_CLUSTER_ID=production-app-cluster
export GCP_PROJECT_ID=production-apps-210001
export GCP_ZONE=us-west1-b
# Docker builds cannot use uppercase characters in the image name
export LOWER_CASE_BRANCH=$(echo -n $TRAVIS_BRANCH | awk '{print tolower($0)}')
export DEPLOYMENT_IMAGE="gcr.io/$GCP_PROJECT_ID/$DEPLOYMENT_IMAGE_PREFIX-$LOWER_CASE_BRANCH:$TRAVIS_COMMIT"
# The current version
export VERSIONS_CURRENT=$(bash themes/pxdocs-tooling/deploy/scripts/versions.sh get-current-branch-version)
# A comma-separated list of all versions. We use this variable to build the version selector.
export VERSIONS_ALL=$(bash themes/pxdocs-tooling/deploy/scripts/versions.sh get-all-versions)
export VERSIONS_TAG=$(echo -n "$VERSIONS_CURRENT" | sed 's/\./-/g')
export ALGOLIA_INDEX_NAME="${PRODUCT_INDEX_NAME}-${VERSIONS_TAG}"
# A comma-separated list of all product names and indices, in the form of `<product-name>=<product-index>`.
export PRODUCT_NAMES_AND_INDICES="${PRODUCT_NAME}=${PRODUCT_INDEX_NAME}-${TRAVIS_BRANCH/./-},${OTHER_PRODUCT_NAMES_AND_INDICES}"

echo "env vars set successfully"