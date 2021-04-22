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


# @test "i2pd socks proxy is up" {
#
# }
