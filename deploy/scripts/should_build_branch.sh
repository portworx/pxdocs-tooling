#!/bin/bash -e
set -e

if [[ $VERSIONS_ALL =~ (^|,)"$TRAVIS_BRANCH"(,|$) ]]; then
  echo yes
else
  echo no
fi
