let
  lib = import <nixpkgs/lib>;
  config = import ./lib/config.nix;
  testNetConfig = config.read ./config.nix;
in {
  network.description = "I2Pd Container Teststand";

  i2ptestnet = { config, pkgs, ... }: {
    boot.enableContainers = true;
 
    environment.systemPackages = with pkgs; [ i2p-tools docker-compose ];

    users.users.tester = {
      group = "tester";
      description = "The Tester user";
      createHome = true;
      uid = 1000;
      extraGroups = ["wheel"];
      initialPassword = "i2ptest";
      isNormalUser = true;
    };

    users.groups.tester.gid = 1000;

    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
    };

    # disable guest additions because we get the wrong version of it most of the time
    # and i don't want to restart and upgrade virtualbox every time to make it all work.
    virtualisation.virtualbox.guest.enable = lib.mkForce false;
    virtualisation.virtualbox.guest.x11 = false;
  };
}
