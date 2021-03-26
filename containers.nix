let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  config = import ./lib/config.nix;
  testNetConfig = config.read ./config.nix;

  node = import ./lib/node.nix;
  container  = import ./lib/container.nix;

  mkContainerNodes = testNetConfig:
    let
      nodeIdList = (lib.range 1 testNetConfig.nodes.amount);
      nodesConfigList = lib.forEach nodeIdList (id:
        let
          nodeConfig = (node.mkConfig id);
        in {
          "${nodeConfig.name}" = container.mkNode testNetConfig nodeConfig;
        }
      );
    in lib.zipAttrsWith (name: values: lib.findFirst (v: true) {} values) nodesConfigList;
in {

  network.description = "I2Pd Container Teststand";

  i2ptestnet = { config, pkgs, ... }: {
    imports = [ ./mypkgs.nix ];

    boot.enableContainers = true;
    containers = {
      "i2p-reseed" = (container.mkReseederNode testNetConfig);
      } // (mkContainerNodes testNetConfig);
 
    # make sure network manager doesn't interfere with the container interfaces
    networking.networkmanager.unmanaged = [ "interface-name:ve-*" ];

    # networking.nat.enable = true;
    # networking.nat.internalInterfaces = [ "ve-i2p-reseed" "ve-i2p-1"];
    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [ 22 ];

    environment.systemPackages = with pkgs; [ i2p-tools ];
  };
}
