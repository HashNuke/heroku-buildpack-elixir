#!/usr/bin/env bash

erlang_builds_url() {
  case "${STACK}" in
    "heroku-20")
      erlang_builds_url="https://builds.hex.pm/builds/otp/ubuntu-20.04"
      ;;
    "heroku-22")
      erlang_builds_url="https://builds.hex.pm/builds/otp/ubuntu-22.04"
      ;;
    "heroku-24")
      erlang_builds_url="https://builds.hex.pm/builds/otp/ubuntu-24.04"
      ;;
    *)
      erlang_builds_url="https://s3.amazonaws.com/heroku-buildpack-elixir/erlang/cedar-14"
      ;;
  esac
  echo $erlang_builds_url
}

fetch_elixir_versions() {
  url="https://builds.hex.pm/builds/elixir/builds.txt"
  curl -s "$url" | awk '/^v[0-9.]+[- ]/ { print $1 }'
}

fetch_erlang_versions() {
  case "${STACK}" in
    "heroku-20")
      url="https://builds.hex.pm/builds/otp/ubuntu-20.04/builds.txt"
      curl -s "$url" | awk '/^OTP-([0-9.]+ )/ {print substr($1,5)}'
      ;;
    "heroku-22")
      url="https://builds.hex.pm/builds/otp/ubuntu-22.04/builds.txt"
      curl -s "$url" | awk '/^OTP-([0-9.]+ )/ {print substr($1,5)}'
      ;;
    "heroku-24")
      url="https://builds.hex.pm/builds/otp/ubuntu-24.04/builds.txt"
      curl -s "$url" | awk '/^OTP-([0-9.]+ )/ {print substr($1,5)}'
      ;;
    *)
      url="https://raw.githubusercontent.com/HashNuke/heroku-buildpack-elixir-otp-builds/master/otp-versions"
      curl -s "$url"
      ;;
  esac
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

exact_elixir_version_available() {
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
    output_line "Sorry, Erlang '$version' isn't supported yet or isn't formatted correctly. For a list of supported versions, please see https://github.com/HashNuke/heroku-buildpack-elixir#version-support"
    exit 1
  fi
}

check_elixir_version() {
  version=$1
  exists=$(exact_elixir_version_available "$version" "$(fetch_elixir_versions)")
  if [ $exists -ne 0 ]; then
    output_line "Sorry, Elixir '$version' isn't supported yet or isn't formatted correctly. For a list of supported versions, please see https://github.com/HashNuke/heroku-buildpack-elixir#version-support"
    exit 1
  fi
}
