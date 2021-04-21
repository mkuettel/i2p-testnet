#!/usr/bin/env bash

set -eu -o pipefail
base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$base_dir/bin:$PATH"

TESTDIR="$(mktemp -d || ( echo "could not create temp test directory" || exit 1 ) )"
touch "$TESTDIR/bats-test-data-dir"
cd "$TESTDIR"
trap "[ -f '$TESTDIR/bats-test-data-dir' ] && rm -rf '$TESTDIR' " EXIT
export TESTDIR

setup_test_dir() {
    cd "$TESTDIR"
    pwd
    local current_testdir="$TESTDIR/$(basename "$BATS_TEST_FILENAME")-$BATS_TEST_NUMBER"
    mkdir -p "$current_testdir"
    cd "$current_testdir"
    export CURRENT_TESTDIR="$current_testdir"

}
