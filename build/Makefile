SHELL := /bin/bash
TOOLING_BRANCH?=master
# The name of the triggering repository
TRIGGERING_REPO_NAME = $(shell basename -s .git `git config --get remote.origin.url`)

# The following environment variables are set based on the triggering repository
prerequisites:
# The triggering repository is Portworx Enterprise (`pxdocs`)
ifeq ($(TRIGGERING_REPO_NAME),pxdocs)
BUILDER_IMAGE?=pxdocs:developer
SEARCH_INDEX_IMAGE?=pxdocs-search-index:developer
DEPLOYMENT_IMAGE?=pxdocs-deployment:developer
PORT?=1313
DEVELOP_CONTAINER_NAME=pxdocs-develop
VOLUME=docs
PUBLISH_CONTAINER_NAME=pxdocs-publish
SEARCH_INDEX_CONTAINER_NAME=pxdocs-search-index
endif
# The triggering repository is PX-Backup (`pxdocs-backup`)
ifeq ($(TRIGGERING_REPO_NAME),pxdocs-backup)
BUILDER_IMAGE?=pxbackup:developer
SEARCH_INDEX_IMAGE?=pxbackup-search-index:developer
DEPLOYMENT_IMAGE?=pxbackup-deployment:developer
PORT?=1515
DEVELOP_CONTAINER_NAME=pxbackup-develop
VOLUME=pxbackup
PUBLISH_CONTAINER_NAME=pxbackup-publish
SEARCH_INDEX_CONTAINER_NAME=pxbackup-publish
SEARCH_INDEX_CONTAINER_NAME=pxbackup-search-index
endif

.PHONY: image
image: prerequisites
	docker build -t $(BUILDER_IMAGE) -f themes/pxdocs-tooling/build/Dockerfile .

.PHONY: search-index-image
search-index-image: prerequisites
	docker build -t $(SEARCH_INDEX_IMAGE) themes/pxdocs-tooling/deploy/algolia

.PHONY: deployment-image
deployment-image: prerequisites
	cp -r themes/pxdocs-tooling/deploy/nginx nginx_build_folder
	cp -r public nginx_build_folder/hugo_public
	cat public/redirects.json | docker run --rm -i stedolan/jq -r '.[] | "rewrite ^\(.from)$$ \(.to) permanent;"' > nginx_build_folder/pxdocs-directs.conf
	docker build -t $(DEPLOYMENT_IMAGE) --build-arg NGINX_REDIRECTS_FILE nginx_build_folder
	rm -rf nginx_build_folder

.PHONY: update-theme reset-theme
update-theme: prerequisites
	git submodule init
	git submodule update
	git submodule foreach git checkout $(TOOLING_BRANCH)
	git submodule foreach git pull origin $(TOOLING_BRANCH)

reset-theme: prerequisites
	git submodule foreach --recursive git clean -xfd
	git reset --hard
	git submodule foreach --recursive git reset --hard
	git submodule update --init --recursive

.PHONY: develop
develop: image
	source ./themes/pxdocs-tooling/build/export-product-url.sh && docker run --rm \
		$(DOCKER_EXTRA_ARGS) \
		--name $(DEVELOP_CONTAINER_NAME) \
		-e VERSIONS_ALL \
		-e VERSIONS_CURRENT \
		-e VERSIONS_BASE_URL \
		-e ALGOLIA_APP_ID \
		-e ALGOLIA_API_KEY \
		-e ALGOLIA_INDEX_NAME \
		-e TRAVIS_BRANCH \
		-e PRODUCT_URL \
		-e PRODUCT_NAMES_AND_INDICES \
		-p $(PORT):$(PORT) \
		-v "$(PWD):/$(VOLUME)" \
		$(BUILDER_IMAGE) server --bind=0.0.0.0 --port $(PORT) --disableFastRender

.PHONY: publish-docker
publish-docker: prerequisites
	source ./themes/pxdocs-tooling/build/export-product-url.sh && docker run --rm \
		--name $(PUBLISH_CONTAINER_NAME) \
		-e VERSIONS_ALL \
		-e VERSIONS_CURRENT \
		-e VERSIONS_BASE_URL \
		-e ALGOLIA_APP_ID \
		-e ALGOLIA_API_KEY \
		-e ALGOLIA_INDEX_NAME \
		-e TRAVIS_BRANCH \
		-e PRODUCT_URL \
		-e PRODUCT_NAMES_AND_INDICES \
		-v "$(PWD):/$(VOLUME)" \
		$(BUILDER_IMAGE) -v --debug --gc --ignoreCache --cleanDestinationDir

.PHONY: search-index-docker
search-index-docker: prerequisites
	source ./themes/pxdocs-tooling/build/export-product-url.sh && docker run --rm \
		--name $(SEARCH_INDEX_CONTAINER_NAME) \
		-v "$(PWD)/public/algolia.json:/app/indexer/public/algolia.json" \
		-e ALGOLIA_APP_ID \
		-e ALGOLIA_API_KEY \
		-e ALGOLIA_ADMIN_KEY \
		-e ALGOLIA_INDEX_NAME \
		-e ALGOLIA_INDEX_FILE=public/algolia.json \
		-e PRODUCT_URL \
		-e PRODUCT_NAMES_AND_INDICES \
		$(SEARCH_INDEX_IMAGE)

.PHONY: check-links
check-links:
	rm -rf htmltest/bin && cd htmltest && curl https://htmltest.wjdp.uk | bash && bin/htmltest -c .htmltest.yml && cd ..

.PHONY: publish
publish: image publish-docker

.PHONY: search-index
search-index: image search-index-image publish-docker search-index-docker
