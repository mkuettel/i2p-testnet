#!/usr/bin/env bats

set -eu -o pipefail

load test-helper

@test "recompose -h shows usage" {
    recompose -h | grep '^Usage: recompose \[-h\]'
}
