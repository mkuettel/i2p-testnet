#!/usr/bin/env bats

set -eu -o pipefail

load test-helper

@test "recompose -h shows usage" {
    recompose -h | grep '^Usage: recompose \[-h\]'
}

# @test "getconf reads config.json in CWD by default" {
#     echo '{"some": {"config": true}}' > config.json
# }
