#!/usr/bin/env bats

set -eu -o pipefail
load ../lib/compose

load test-helper


setup() {
  setup_test_dir
}

teardown() {
    true
}

@test "generate_node_config sets correct container_name" {
    echo '{"network": {"private": false}}' > config.json
    config_file=config.json

    container_name="$(generate_node_config 10 | jq -r ".i2pd_10.container_name")"

    [ "$container_name" = "\${COMPOSE_PROJECT_NAME}_i2pd_10" ]
}

@test "generate_node_config sets correct ip" {
    echo '{"network": {"private": false}}' > config.json
    config_file=config.json

    generate_node_config 10 | grep -F '"ipv4_address": "10.23.128.10"'
    generate_node_config 1 | grep -F '"ipv4_address": "10.23.128.1"'
    generate_node_config 256 | grep -F '"ipv4_address": "10.23.129.0"'
    generate_node_config 300 | grep -F '"ipv4_address": "10.23.129.44"'
}

@test "generate_node_config sets reseeder in private network" {
    echo '{"network": {"private": true}}' > config.json
    config_file=config.json
    RESEED_IP=10.23.0.10

    url=$(generate_node_config 11 | jq -r '.i2pd_11.environment.RESEED_WAIT_URL')
    [ "$url" = "http://$RESEED_IP:8443/i2pseeds.su3" ]
}

@test "generate_node_config sets adds volume for i2pd data" {
    echo '{"network": {"private": false}}' > config.json
    config_file=config.json

    volume_spec=$(generate_node_config 5 | jq -r '.i2pd_5.volumes[0]')
    echo "$volume_spec"
    [ "$volume_spec" = "./docker/volumes/i2pd-data-5:/home/i2pd/data" ]
}

@test "generate_node_config doesn't set reseeder in public network" {
    echo '{"network": {"private": false}}' > config.json
    config_file=config.json

    url=$(generate_node_config 7 | jq -r '.i2pd_7.environment.reseed_wait_url')
    [ "$url" = "null" ]
}

@test "generate_all_node_configs generates right amount of nodes" {
    echo '{"network": {"private": false}, "nodes": {"amount": 6}}' > config.json
    config_file=config.json

    diff <(seq -f 'i2pd_%g' 1 6) <(generate_all_node_configs 6 | jq -r '.services | keys | .[]')
}
