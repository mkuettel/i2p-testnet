
getconf() {
    local attr="$1"
    jq ".$attr" < "$config_file" || (
        echo "ERROR: could not read configuration file" 1>&2
        exit 4
    )
}

num_router_infos() {
    printf "%s\n" "$reseed_netdb_dir"/routerInfo-*.dat | wc -l
}

collect_router_infos() {
    local amount="$(getconf 'nodes.amount')"
    local num_errs=0

    # copy until we have a router info from every node
    while [[ "$(num_router_infos)" -lt "$amount" ]]; do
        for i in $(seq 1 "$amount"); do
            srcri="$base_dir/docker/volumes/i2pd-data-$i"/router.info
            if [[ -s "$srcri" ]]; then
                cp "$srcri" "$reseed_netdb_dir"/routerInfo-"$i".dat
            fi
        done
    done

    # generate and distribute addressbook
    generate_addressbook > "addressbook.csv"
    for i in $(seq 1 "$amount"); do
        echo "copying addrbook $i"
        # docker cp "addressbook.csv" "${COMPOSE_PROJECT_NAME}_i2pd_${i}":/home/i2pd/data/addressbook/addresses.csv
        cp "addressbook.csv" "docker/volumes/i2pd-data-$i"/addressbook/addresses.csv
    done

    touch "$reseed_netdb_dir"/.router-infos-collected
}

generate_addressbook() {
    printf "%s\n" "$base_dir"/docker/volumes/i2pd-data-*/destinations/* \
        | sed 's@^.*docker/volumes/i2pd-data-\([0-9]\+\)/destinations/\(.*\).dat$@tcpsrv-\1.i2p,\2@g' \
        | sort -t '-' -n -k2

}

generate_node_config() {
    local id="$1"
    local segment3=$((id / 256 + 128))
    local segment4=$((id % 256))

    local nodefile="$(mktemp)"

    jq  --arg ipv4_address "10.23.${segment3}.${segment4}" \
        --arg name "\${COMPOSE_PROJECT_NAME}_i2pd_$id" \
        --arg volume_dir "./docker/volumes/i2pd-data-$1:/home/i2pd/data" \
        ' .container_name = $name
        | .networks["i2ptestnet"]["ipv4_address"] = $ipv4_address
        | .volumes += [$volume_dir]
        ' \
        < "$base_dir"/docker/i2p-node-base.json \
        > "$nodefile"

    if [[ "$(getconf network.private)" == "true" ]]; then
        jq  --arg reseed_wait_url "http://$RESEED_IP:8443/i2pseeds.su3" \
            '.environment["RESEED_WAIT_URL"] = $reseed_wait_url' \
            < "$nodefile" \
            | sponge "$nodefile"
    fi

    jq --arg i $1 '{("i2pd_" + $i): .}' < "$nodefile"
    rm "$nodefile"
}

generate_all_node_configs() {
    local amount="$1"

    (
        for i in $(seq 1 "$amount"); do
            generate_node_config "$i"
        done
    )   | jq -s 'add | {"version": "3.8", "services": .}'
}


cleanup_volume_dirs() {
    rm -r "$base_dir"/docker/volumes/i2pd-data-* || true
}

create_volume_dirs() {
    local amount="$1"
    seq -f "$base_dir/docker/volumes/i2pd-data-%g" 1 "$amount" | xargs mkdir || true
}
