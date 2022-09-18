# try to pull from porx

# We need to decide if we only want to run this on upstream builds, or also for PRs. We currently don't export ecypted env vars to PRs, so I'll have this exit. 
# if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then 
#     echo "this is a PR, exting"
#     exit 0; 
# fi

echo "checking $GH_BOT_TOKEN"
# Ensure that the token is set
if [ -z "$GH_BOT_TOKEN" ] ; then
    echo "Travis env vars missing a github personal token"
    exit 1
fi

echo "checking $LATEST_VERSION"
# Ensure the env vars are set successfully
if [ -z "$LATEST_VERSION" ] ; then
    echo "Missing LATEST_VERSION env var"
    exit 1
fi

echo "checking $YAML_SECTION_NAME"
if [ -z "$YAML_SECTION_NAME" ] ; then
    echo "Missing YAML_SECTION_NAME env var"
    exit 1
fi

echo "checking $TRIGGERING_REPO_NAME"
if [ -z "$TRIGGERING_REPO_NAME" ] ; then
    echo "Missing TRIGGERING_REPO_NAME env var"
    exit 1
fi

echo "checking $PX_ENTERPRISE_REPO_NAME"
if [ -z "$PX_ENTERPRISE_REPO_NAME" ] ; then
    echo "Missing PX_ENTERPRISE_REPO_NAME env var"
    exit 1
fi

echo "building branch variable"
# build the Portworx branch string
branch=gs-rel-${LATEST_VERSION}.0

echo $branch

echo "getting data from porx"

# Get yamls from porx
curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/alerts.yaml\
		--output ../../../data/alerts.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/auth.yaml\
		--output ../../../data/auth.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/clouddrive.yaml\
		--output ../../../data/clouddrive.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/cloudmigrate.yaml\
		--output ../../../data/cloudmigrate.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/cloudsnap.yaml\
		--output ../../../data/cloudsnap.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/cluster.yaml\
		--output ../../../data/cluster.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/context.yaml\
		--output ../../../data/context.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/credentials.yaml\
		--output ../../../data/credentials.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/eula.yaml\
		--output ../../../data/eula.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/host.yaml\
		--output ../../../data/host.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/license.yaml\
		--output ../../../data/license.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/objectstore.yaml\
		--output ../../../data/objectstore.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/role.yaml\
		--output ../../../data/role.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/sched-policy.yaml\
		--output ../../../data/sched-policy.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/secrets.yaml\
		--output ../../../data/secrets.yaml

curl -H "Authorization: bearer $GH_BOT_TOKEN" \
https://raw.githubusercontent.com/portworx/porx/${branch}/px/pxctl/spec/service.yaml\
		--output ../../../data/service.yaml

# Verify the file has been created
fileread=$(cat /alerts/sdk.yaml)
echo "${fileread}"

# Hugo will pick up the YAML value and render it into the docs using a shortcode


# We should probably shuffle the build scripts around some.
# 1. init env vars in the `before_install.sh` file, or define a new one that inits all env vars that build scripts will use
# 2. run scripts that pull data
# 3. run hugo, etc. 

# Wishlist:
# * an override setting that allows us to run this locally and build a file that can be used to override the automated output. We can put an if statement into
#   the template to pull the override file rather than the generated one if it exists. This would be most useful in other data pull scripts, maybe not here.