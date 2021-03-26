let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  config = import ./lib/config.nix;
  testNetConfig = config.read ./config.nix;

  hostAddress = "10.23.0.1/16";

  node = import ./lib/node.nix;

  mkContainerNode = nodeConfig: rec {
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
    # hostBridge = "br${builtins.toString nodeConfig.id}";
    hostAddress = nodeConfig.hostAddress;
    localAddress = nodeConfig.localAddress;
  };

  mkReseederNode = testNetConfig: {
    "i2p-reseed" = {
      config = import ./machines/seeder/configuration.nix;
      autoStart = true;
      ephemeral = true;
      privateNetwork = true;

      # extraVeths = {
      #   "v-host" = {
      #     localAddress = "10.23.0.100/16";
      #     inherit hostAddress;
      #   };
      # };
      #
      # localAddress = "10.23.0.100/16";
      localAddress = "10.0.0.2";
      hostAddress = "10.0.0.1";
      # hostBridge = "br0";
      # inherit hostAddress;
    };
  };

  mkContainerNodes = testNetConfig:
    let
      nodeIdList = (lib.range 1 testNetConfig.nodes.amount);
      nodesConfigList = lib.forEach nodeIdList (id:
        let
          nodeConfig = (node.mkConfig id);
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
 
    # make sure network manager doesn't interfere with the container interfaces
    networking.networkmanager.unmanaged = [ "interface-name:ve-*" ];

    # networking.nat.enable = true;
    # networking.nat.internalInterfaces = [ "ve-i2p-reseed" "ve-i2p-1"];
    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [ 22 ];

    environment.systemPackages = with pkgs; [ i2p-tools ];
  };
}
