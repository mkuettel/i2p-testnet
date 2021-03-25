let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  config = import ./lib/config.nix;
  testNetConfig = config.read ./config.nix;

  mkNodeConfig = id: {
    inherit id;
    name = "node-${id}";
  };

  mkContainerNode = nodeConfig: {
    config = import ./machines/node/configuration.nix;
  };

  mkContainerNodes = testNetConfig:
    let
      nodeIdList = (lib.range 1 testNetConfig.nodes.amount);
      nodesConfigList = lib.forEach nodeIdList (id: {
        "i2p-node-${builtins.toString id}" = mkContainerNode (mkNodeConfig id);
      });
    in lib.zipAttrsWith (name: values: lib.findFirst (v: true) {} values) nodesConfigList;
in {
  network.description = "I2Pd Container Teststand";

  i2ptestnet = { config, pkgs, ... }: {
    boot.enableContainers = true;

    containers = mkContainerNodes testNetConfig;
  };
}
