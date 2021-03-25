let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  config = import ./lib/config.nix;
  testNetConfig = config.read ./config.nix;

  mkNodeConfig = id: {
    inherit id;
    name = "i2p-node-${builtins.toString id}";
  };

  mkContainerNode = nodeConfig: {
    autoStart = true;
    # rebuild container from scratch (more reproducability, but takes longer to start tests)
    ephemeral = true;
    # bindMounts = {
    #     "/home/i2p"
    # };
    config = import ./machines/node/configuration.nix;
  };

  mkContainerNodes = testNetConfig:
    let
      nodeIdList = (lib.range 1 testNetConfig.nodes.amount);
      nodesConfigList = lib.forEach nodeIdList (id:
        let
          nodeConfig = (mkNodeConfig id);
        in {
          "${nodeConfig.name}" = mkContainerNode nodeConfig;
        }
      );
    in lib.zipAttrsWith (name: values: lib.findFirst (v: true) {} values) nodesConfigList;
in {

  network.description = "I2Pd Container Teststand";

  i2ptestnet = { config, pkgs, ... }: {
    imports = [ ./nixpkgs.nix ];

    boot.enableContainers = true;

    containers = mkContainerNodes testNetConfig;
  };
}
