
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

    # copy until we have a router info from every node
    while [[ "$(num_router_infos)" -lt "$amount" ]]; do
        for i in $(seq 1 "$amount"); do
            if [[ ! -f "$reseed_netdb_dir"/routerInfo-"$i".dat ]]; then
                docker cp "${COMPOSE_PROJECT_NAME}_i2pd_$i":/home/i2pd/data/router.info "$reseed_netdb_dir"/routerInfo-"$i".dat || true

                ## delete if file is empty to refetch it again if necesscary
                if [[ -f "$reseed_netdb_dir"/routerInfo-"$i".dat && ( ! -s "$reseed_netdb_dir"/routerInfo-"$i".dat ) ]]; then
                    rm "$reseed_netdb_dir"/routerInfo-"$i".dat || true
                fi
            fi
            # docker cp "${COMPOSE_PROJECT_NAME}_i2pd_$i":/home/i2pd/data/destinations "$addressbook_dir" || true
        done
    done

    touch "$reseed_netdb_dir"/.router-infos-collected
}
