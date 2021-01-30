#!/usr/bin/env bash

erlang_builds_url() {
  # TODO: use ubuntu-20.04 if applicable
  # use new STACK env var: STACK=heroku-20
  erlang_builds_url="https://repo.hex.pm/builds/otp/ubuntu-20.04"
  echo $erlang_builds_url
}

erlang_versions_url() {
  # TODO: use ubuntu-20.04 if applicable
  # TODO: fallback to hashnuke one if not ubuntu-20.04 and not found on hex
  url="https://repo.hex.pm/builds/otp/ubuntu-20.04/builds.txt"
  echo $url
}

fetch_erlang_versions() {
  curl -s "$(erlang_versions_url)" | awk '/^OTP-([0-9.]+ )/ {print substr($1,5)}' | sort
}

exact_erlang_version_available() {
  version=$1
  available_versions=$2
  found=1
  while read -r line; do
    if [ "$line" = "$version" ]; then
      found=0
    fi
  done <<< "$available_versions"
  echo $found
}

check_erlang_version() {
  version=$1
  exists=$(exact_erlang_version_available "$version" "$(fetch_erlang_versions)")
  if [ $exists -ne 0 ]; then
    output_line "Sorry, Erlang $version isn't supported yet. For a list of supported versions, please see $(erlang_versions_url)"
    exit 1
  fi
}

