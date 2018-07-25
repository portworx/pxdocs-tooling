#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMAGE=${IMAGE:=px-docs-indexer:latest}

docker rm -f px-docs-indexer || true
docker build -t $IMAGE -f Dockerfile.indexer .
docker run --rm \
  --name px-docs-indexer \
  -v $PWD/public/algolia.json:/algolia.json:ro \
  -e ALGOLIA_APP_ID \
  -e ALGOLIA_ADMIN_KEY \
  -e ALGOLIA_API_KEY \
  -e ALGOLIA_INDEX_NAME \
  -e ALGOLIA_INDEX_FILE=public/algolia.json \
  $IMAGE
