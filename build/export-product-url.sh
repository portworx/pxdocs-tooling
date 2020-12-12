# Federated search requires us to append a prefix in the form of `<protocol><version>` to all URLs that get uploaded to Algolia. This script determines this prefix and saves it in the `PRODUCT_URL` environment variable.
VERSION=""
URL=""
PROTO="https://"
PROTO_AND_VERSION=""

# If one of the following environment variables is undefined, then we assume that this script runs on a development machine. We don't modify the values of the `VERSION` or `URL` variables. The prefix will be an empty string.
if [ -z "$TRAVIS_BRANCH" ] || [ -z "$BRANCH_VERSION_CONFIG" ] || [ -z "$VERSIONS_BASE_URL" ]
then
  echo "One of the following environment variables is not defined: \$TRAVIS_BRANCH, \$BRANCH_VERSION_CONFIG."
# If these environment variables are defined, then we assume that this script runs in Travis.
else
  # The `BRANCH_VERSION_CONFIG` environment variable is a comma-separated list of branches and versions for which we build the deployment image, update the Algolia index and push the image to GCP. If `BRANCH_VERSION_CONFIG` contains `TRAVIS_BRANCH`, then we assume that this script runs in Travis, and begin constructing the URL by setting `URL` to the base URL (`VERSIONS_BASE_URL).
  if [[ $BRANCH_VERSION_CONFIG == *$TRAVIS_BRANCH* ]]
  then
    echo "\$TRAVIS_BRANCH = $TRAVIS_BRANCH is in \$BRANCH_VERSION_CONFIG = $BRANCH_VERSION_CONFIG"
    URL=$VERSIONS_BASE_URL
    echo "\$LATEST_VERSION is $LATEST_VERSION"
    # If we build the latest version, then we don't need to add the version to the URL
    if [[ "$LATEST_VERSION" == "$TRAVIS_BRANCH" ]]
    then
      PROTO_AND_VERSION="$PROTO"
    # If we are not building the latest version, then we add the version to the URL
    else
      PROTO_AND_VERSION="$PROTO$TRAVIS_BRANCH."
    fi
  # If `BRANCH_VERSION_CONFIG` doesn't contain `TRAVIS_BRANCH`, then we're probably building the `master` branch. We still build the URL because otherwise our link checker would fail, but we don't add the version to the URL.
  else
    echo "\$TRAVIS_BRANCH = $TRAVIS_BRANCH is not in \$BRANCH_VERSION_CONFIG = $BRANCH_VERSION_CONFIG"
    URL=$VERSIONS_BASE_URL
    PROTO_AND_VERSION="$PROTO"
  fi
fi

echo "\$PRODUCT_URL is $PROTO_AND_VERSION$URL"
export PRODUCT_URL=$PROTO_AND_VERSION$URL
