#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/lib/canonical_version.sh

VERSIONS=$(fetch_erlang_versions)

testExactErlangVersionAvailable() {
  assertEquals 0 $(exact_erlang_version_available "22.0.3" "$VERSIONS")
}

testExactErlangVersionUnavailable() {
  assertEquals 1 $(exact_erlang_version_available "22.0.1" "$VERSIONS")
}

testExactErlangVersionMajorOnly() {
  assertEquals 1 $(exact_erlang_version_available "21" "$VERSIONS")
}

testExactErlangVersionMajorMinorOnly() {
  assertEquals 0 $(exact_erlang_version_available "21.0" "$VERSIONS")
}
