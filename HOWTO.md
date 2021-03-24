# User Manual

## Prerequisites

You need to have [nix](https://github.com/nixos/nix) installed to have access to the [nix package collection (nixpkgs)](https://github.com/nixos/nixpkgs).
You also need to install nixops:

    $ nix-env -iA nixpkgs.nixops

## Configuration

The `config.nix` file is the configuration for the testnet.

## Virtual box / containers

First deployment:

    $ nixops create containers deployment/vbox-containers.nix -d i2pdvbox
    $ nixops deploy -d i2pdvbox

Get rid of VM & deployment:

    $ nixops destroy -d i2pdvbox
    $ nixops delete  -d i2pdvbox
