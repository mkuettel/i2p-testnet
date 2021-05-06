#!/usr/bin/env bats

set -eu -o pipefail

load test-helper

setup() {
    tcpserver msglog.csv &
    pid=$!
}

teardown() {
    kill "$pid" || true
}

@test "tcpserver writes message log for a single message" {
    echo '"garbagedata*one,two,three,four$' | nc -N localhost 2323

    kill "$pid"
    egrep 'one,two,three,four,[0-9]+' msglog.csv
}

@test "tcpserver writes message log for multiple messages" {
    echo '"garbagedata*one,two,three,four$"garbagedata*1,2,3,4$' | nc -N localhost 2323

    kill "$pid"
    egrep 'one,two,three,four,[0-9]+' msglog.csv
    egrep '1,2,3,4,[0-9]+' msglog.csv
}

@test "tcpserver can handle 256 concurrent clients" {
    for i in $(seq 1 256); do
        echo '"garbagedata*one,two,three,four$"garbagedata*1,2,3,4$' | nc -N localhost 2323
    done

    kill "$pid"
    [ "$(egrep -c 'one,two,three,four,[0-9]+' msglog.csv)" -eq 256 ]
    [ "$(egrep -c '1,2,3,4,[0-9]+' msglog.csv)" -eq 256 ]
}
