#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/lib/canonical_version.sh

testEquality() {
  assertEquals 1 1
}

testExactVersion() {
  newVersion=$(canonicalVersion 1.2.3)
  assertEquals $newVersion 1.2.3
}



