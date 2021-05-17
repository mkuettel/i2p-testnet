
BANDWIDTHS=(100000)

getconf() {
    local attr="$1"
    jq -r ".$attr" < "$config_file" || (
        echo "ERROR: could not read configuration file" 1>&2
        exit 4
    )
}

num_router_infos() {
    printf "%s\n" "$reseed_netdb_dir"/routerInfo-*.dat | wc -l
}


destination_addr_exists() {
    local voldir="$1"
    [[ "$(ls -1 "$voldir"/destinations | grep -c '.dat$')" -ge 1 && -s "$(printf '%s' "$voldir"/destinations/*.dat)"  ]]
}

collect_router_infos() {
    local amount="$(getconf 'nodes.amount')"
    local voldir=
    local oknodes=0
    local starttimefile=`mktemp`

    # copy until we have an up-to-date router info from every node
    while [[ "$oknodes" -lt "$amount" ]]; do
        oknodes=0
        for i in $(seq 1 "$amount"); do
            voldir="$base_dir/docker/volumes/i2pd-data-$i"
            # is router info & destination ready?
            if [[ -s "$voldir/router.info" && ! "$voldir/router.info" -ot "$starttimefile" ]] && destination_addr_exists "$voldir"; then
                cp "$voldir/router.info" "$reseed_netdb_dir"/routerInfo-"$i".dat
                oknodes=$((oknodes + 1))
            fi
        done
    done

    # generate and distribute addressbook
    generate_addressbook > "addressbook.csv"
    for i in $(seq 1 "$amount"); do
        echo "copying addrbook $i"
        cp "addressbook.csv" "docker/volumes/i2pd-data-$i"/addressbook/addresses.csv
    done

    sleep 1
    sync
    touch "$reseed_netdb_dir"/.router-infos-collected
    sync
}

generate_addressbook() {
    printf "%s\n" "$base_dir"/docker/volumes/i2pd-data-*/destinations/* \
        | sed 's@^.*docker/volumes/i2pd-data-\([0-9]\+\)/destinations/\(.*\).dat$@tcpsrv-\1.i2p,\2@g' \
        | sort -t '-' -n -k2

}

generate_node_config() {
    local id="$1"
    local i2pd_config_file="$2"
    local segment3=$((id / 256 + 128))
    local segment4=$((id % 256))

    local nodefile="$(mktemp)"

    jq  --arg ipv4_address "10.23.${segment3}.${segment4}" \
        --arg name "\${COMPOSE_PROJECT_NAME}_i2pd_$id" \
        --arg volume_dir "./docker/volumes/i2pd-data-$1:/home/i2pd/data" \
        --arg confarg "i2pd_config_file=$i2pd_config_file" \
        --arg bandwidth "$(get_bandwidth "$id")" \
        ' .container_name = $name
        | .networks["i2ptestnet"]["ipv4_address"] = $ipv4_address
        | .volumes += [$volume_dir]
        | .build.args += [$confarg]
        | .environment["BANDWIDTH"] = $bandwidth
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
    local i2pd_config_file="$2"

    (
        for i in $(seq 1 "$amount"); do
            generate_node_config "$i" "$i2pd_config_file"
        done
    )   | jq -s 'add | {"version": "3.8", "services": .}'
}

get_bandwidth() {
    local id="$1"
    local n="${#BANDWIDTHS[@]}"
    local idx="$(( (id - 1) % n ))"

    echo "${BANDWIDTHS[idx]}"
}

read_bandwidths() {
    readarray -t BANDWIDTHS < <(getconf 'nodes.bandwidth[]')
}


cleanup_volume_dirs() {
    rm -r "$base_dir"/docker/volumes/i2pd-data-* || true
}

create_volume_dirs() {
    local amount="$1"
    seq -f "$base_dir/docker/volumes/i2pd-data-%g" 1 "$amount" | xargs mkdir || true
}
