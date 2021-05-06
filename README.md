# I2P Testnet

## Folder Structure

* `services/`: In here you can find nixos module configuration files.
* `machines/`: In here you can find the different kind of machine configuriations.
* `machines/node`: Configuretion of an I2P node with an Eepsite running in a container

### Clean up network

    docker ps | awk 'NR>1 { print $1 }' | xargs docker kill
