#!/bin/bash -e
set -e


# BRANCH_VERSION_CONFIG=master=1.4,1.3=1.3
# BRANCH_VERSION_CONFIG=<branch>=<version>,<branch>=<version>

CURRENT_BRANCH="$TRAVIS_BRANCH"
IFS=',' read -r -a BRANCH_VERSION_CONFIG_ARRAY <<< "$BRANCH_VERSION_CONFIG"

function join_by { local IFS="$1"; shift; echo "$*"; }

function get-value-from-chunk() {
  local CONFIG="$1"
  local VALUE_INDEX="$2"
  IFS='=' read -r -a CHUNK_PARTS <<< "$CONFIG"
  echo "${CHUNK_PARTS[$VALUE_INDEX]}" 
}

function get-branch-from-chunk() {
  get-value-from-chunk "$1" "0"
}

function get-version-from-chunk() {
  get-value-from-chunk "$1" "1"
}

# print a comma seperated list of all versions
function get-all-versions() {
  local ALL_VERSIONS=""
  for SINGLE_BRANCH_VERSION_CONFIG in "${BRANCH_VERSION_CONFIG_ARRAY[@]}"
  do
    local SINGLE_VERSION=$(get-version-from-chunk "$SINGLE_BRANCH_VERSION_CONFIG")
    if [[ -n "$ALL_VERSIONS" ]]; then
      ALL_VERSIONS="$ALL_VERSIONS,"
    fi
    ALL_VERSIONS="$ALL_VERSIONS$SINGLE_VERSION"
  done
  echo "$ALL_VERSIONS"
}

# print the version for the current branch
function get-current-branch-version() {
  for SINGLE_BRANCH_VERSION_CONFIG in "${BRANCH_VERSION_CONFIG_ARRAY[@]}"
  do
    local SINGLE_BRANCH=$(get-branch-from-chunk "$SINGLE_BRANCH_VERSION_CONFIG")
    local SINGLE_VERSION=$(get-version-from-chunk "$SINGLE_BRANCH_VERSION_CONFIG")
    if [[ "$SINGLE_BRANCH" == "$CURRENT_BRANCH" ]]; then
      echo "$SINGLE_VERSION"
    fi
  done
}

# is the current branch present in the BRANCH_VERSION_CONFIG
function should-build-current-branch() {
  local CURRENT_VERSION=$(get-current-branch-version)
  if [[ -n "$CURRENT_VERSION" ]]; then
    echo "yes";
  fi
}

eval "$@"