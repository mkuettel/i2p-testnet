let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  config = import ./lib/config.nix;
  testNetConfig = config.read ./config.nix;

  node = import ./lib/node.nix;
  container  = import ./lib/container.nix;

  nodeConfigs = let
      nodeIdList = (lib.range 1 testNetConfig.nodes.amount);
  in lib.forEach nodeIdList node.mkConfig;

  mkContainerNodes = testNetConfig: let
      containerNodes = lib.forEach nodeConfigs (nodeConfig: {
        "${nodeConfig.name}" = container.mkNode testNetConfig nodeConfig;
      });
    in lib.zipAttrsWith (name: values: lib.findFirst (v: true) {} values) containerNodes;
in {

  network.description = "I2Pd Container Teststand";

  i2ptestnet = { config, pkgs, ... }: {
    imports = [ ./mypkgs.nix ];

    boot.enableContainers = true;
    containers = {
      "i2p-reseed" = (container.mkReseederNode testNetConfig);
      } // (mkContainerNodes testNetConfig);
 
    networking = {
      enableIPv6 = false;

      firewall = {
        enable = false;
        allowedTCPPorts = [ 22 ]; # ssh
      };

      # interfaces = let
      #   interfaceAddresses = lib.forEach nodeConfigs (nodeConfig: {
      #     "${nodeConfig.interfaceName}" = {
      #       virtual = true;
      #       useDHCP = false;
      #       ipv6 = {
      #         routes = [{
      #           address = nodeConfig.networkAddress6;
      #           prefixLength = nodeConfig.prefixLength6;
      #         }];
      #         addresses = [{
      #           address = nodeConfig.hostAddress6;
      #           prefixLength = nodeConfig.prefixLength6;
      #         }];
      #       };
      #     };
      #   });
      # in lib.zipAttrsWith (name: values: lib.findFirst (v: true) {} values) interfaceAddresses; 

      nat = {
        enable = true;
        internalInterfaces = ["ve-+"];
        externalInterface = "enp0s3"; # TODO: is this garuanteed to be here? only in VMWARE?
      };
      networkmanager.unmanaged = [ "interface-name:ve-*" ];
    };
    # networking.bridges."br0" = { rstp = false; interfaces = ["ve-i2p-reseed"]; };
    # networking.nat.enable = true;
    # networking.nat.internalInterfaces = [ "ve-i2p-reseed" ]
    #   ++ lib.forEach nodeConfigs (nodeConfig: nodeConfig.ifname);

    environment.systemPackages = with pkgs; [ i2p-tools ];

    # disable guest addtions because we get the wrong version of it most of the time
    # and i don't want to restart and upgrade virtualbox every time to make it all work.
    virtualisation.virtualbox.guest.enable = lib.mkForce false;
    virtualisation.virtualbox.guest.x11 = false;
  };
}
