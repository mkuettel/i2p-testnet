#!/usr/bin/env bats

set -eu -o pipefail
load ../lib/compose

load test-helper

@test "i2pd can ping reseeder" {
    docker exec testnet_i2pd_1 ping -c1 10.23.0.2
}

@test "reseeder can ping i2pd" {
    docker exec testnet_reseed ping -c1 10.23.128.1
}

@test "i2pd node cannot ping internet" {
    run docker exec testnet_i2pd_2 ping -c1 8.8.8.8

    [ "$status" -eq 1 ] 
    grep '100% packet loss' <<<"$output"
}

@test "i2pd can ping other i2pd" {
    docker exec testnet_i2pd_1 ping -c1 10.23.128.2
    docker exec testnet_i2pd_2 ping -c1 10.23.128.1
}

@test "reseeder serves a seed file" {
    docker exec testnet_reseed sh \
        -c 'wget --no-check-certificate https://10.23.0.2:8443/i2pseeds.su3 -O- | grep I2Psu3'
}

@test "i2p node can access seed file" {
    docker exec testnet_i2pd_1 curl -kf https://10.23.0.2:8443/i2pseeds.su3
}

@test "i2p node socks proxy is running" {
    docker exec testnet_i2pd_2 netstat -tlpn | grep '127.0.0.1:4445'
}

@test "i2p node can access other i2p nodes server tunnel" {
    destination=$(docker exec testnet_i2pd_1 ls /home/i2pd/data/destinations | sed 's/\.dat/.b32.i2p/g')

    docker exec -d testnet_i2pd_1 sh -c 'echo "hello from server" | nc -w 1 -l -p 2323 127.0.0.1'
    docker exec testnet_i2pd_2 curl -sS -x socks5h://127.0.0.1:4445 "telnet://$destination:2323" --data "hi" > msg

    [ "$(cat msg)" = "hello from server" ]
}
