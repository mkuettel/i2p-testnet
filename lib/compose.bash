
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
    while [[ "$(num_router_infos)" -lt "$amount" && "$num_errs" -lt $((amount * 10)) ]]; do
        for i in $(seq 1 "$amount"); do
            if [[ ! -f "$reseed_netdb_dir"/routerInfo-"$i".dat ]]; then
                if docker cp "${COMPOSE_PROJECT_NAME}_i2pd_$i":/home/i2pd/data/router.info "$reseed_netdb_dir"/routerInfo-"$i".dat; then
                    num_errs=0
                    ## delete if file is empty to refetch it again if necesscary
                    if [[ -f "$reseed_netdb_dir"/routerInfo-"$i".dat && ( ! -s "$reseed_netdb_dir"/routerInfo-"$i".dat ) ]]; then
                        rm "$reseed_netdb_dir"/routerInfo-"$i".dat || true
                    fi
                else
                    num_errs=$((num_errs + 1))
                fi
            fi
            # docker cp "${COMPOSE_PROJECT_NAME}_i2pd_$i":/home/i2pd/data/destinations "$addressbook_dir" || true
        done
    done

    touch "$reseed_netdb_dir"/.router-infos-collected
}

generate_node_config() {
    local id="$1"
    local segment3=$((id / 256 + 128))
    local segment4=$((id % 256))

    local ipv4_address="10.23.${segment3}.${segment4}"

    local nodefile="$(mktemp)"

    jq  --arg ipv4_address "$ipv4_address" \
        '.networks["i2ptestnet"]["ipv4_address"] = $ipv4_address' \
        < "$base_dir"/docker/i2p-node-base.json \
        > "$nodefile"

    if [[ "$(getconf network.private)" == "true" ]]; then
        jq  --arg reseed_wait_url "http://10.23.0.1:8443/i2pseeds.su3" \
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
    )   | jq -s 'add' \
        | jq '{"version": "3.8", "services": .}'
}
