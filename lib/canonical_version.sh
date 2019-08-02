#!/usr/bin/env bash

fetch_erlang_versions() {
  url="https://raw.githubusercontent.com/HashNuke/heroku-buildpack-elixir-otp-builds/master/otp-versions"
  curl -s "$url" 
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
    output_line "Sorry, Erlang $version isn't supported yet. For a list of supported versions, please see https://github.com/HashNuke/heroku-buildpack-elixir#version-support"
    exit 1
  fi
}

