let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  config = import ./lib/config.nix;
  testNetConfig = config.read ./config.nix;

  mkNodeConfig = id: {
    inherit id;
    name = "i2p-${builtins.toString id}";
  };

  mkContainerNode = nodeConfig: {
    config = import ./machines/node/configuration.nix;

    autoStart = true;
    # rebuild container from scratch (more reproducability, but takes longer to start tests)
    ephemeral = true;
    # bindMounts = {
    #     "/home/i2p"
    # };

    # don't share interfaces with the host
    # give the containers an own network interface, so the containers don't bind 
    # on ports on the host
    privateNetwork = true;
  };

  mkReseederNode = testNetConfig: {
    "i2p-reseed" = {
      config = import ./machines/seeder/configuration.nix;
      autoStart = true;
      ephemeral = true;
      privateNetwork = true;
    };
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
    imports = [ ./mypkgs.nix ];

    boot.enableContainers = true;
    containers =
      (mkReseederNode testNetConfig) //
      (mkContainerNodes testNetConfig);

    containers = mkContainerNodes testNetConfig;
  };
}
