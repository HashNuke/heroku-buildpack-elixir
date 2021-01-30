#!/usr/bin/env bash

erlang_builds_url() {
  if [ "$STACK" = "heroku-20" ]; then
    erlang_builds_url="https://repo.hex.pm/builds/otp/ubuntu-20.04"
  else
    erlang_builds_url="https://s3.amazonaws.com/heroku-buildpack-elixir/erlang/cedar-14"
  fi
  echo $erlang_builds_url
}

fetch_erlang_versions() {
  if [ "$STACK" = "heroku-20" ]; then
    url="https://repo.hex.pm/builds/otp/ubuntu-20.04/builds.txt"
    curl -s "$url" | awk '/^OTP-([0-9.]+ )/ {print substr($1,5)}'
  else
    url="https://raw.githubusercontent.com/HashNuke/heroku-buildpack-elixir-otp-builds/master/otp-versions"
    curl -s "$url"
  fi
}

exact_erlang_version_available() {
  # TODO: fallback to hashnuke one if not ubuntu-20.04 and not found on hex
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

