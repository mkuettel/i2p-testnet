# User Manual

## Prerequisites

You need to have [nix](https://github.com/nixos/nix) installed to have access to the [nix package collection (nixpkgs)](https://github.com/nixos/nixpkgs).

You also need to install [nixops](https://github.com/NixOS/nixops):

    $ nix-env -iA nixpkgs.nixops

In order to have reproducible deployments you also need [direnv](https://direnv.net/). Required?

    $ nix-env -iA nixpkgs.direnv

Then make sure to hook direnv into your shell as described here:

[https://direnv.net/docs/hook.html](https://direnv.net/docs/hook.html)

This is required to automatically use a pinned nixpkgs version.

## Setup

    $ git clone https://codeberg.org/mkuettel/i2p-testnet.git
    $ cd i2p-testnet
    $ direnv allow .

## Configuration

The `config.nix` file is the configuration for the testnet.

## Virtual box / containers

First deployment:

    $ nixops create containers deployment/vbox-containers.nix -d i2pdvbox
    $ nixops deploy -d i2pdvbox

Get rid of VM & deployment:

    $ nixops destroy -d i2pdvbox
    $ nixops delete  -d i2pdvbox

### Pitfalls

You need to make sure that the version of VirtualBox used on the Hostsystem is compatible with the packaged version of the VirtualBox guest additions.
