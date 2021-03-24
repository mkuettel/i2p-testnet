{
  network.description = "I2Pd Container Teststand";

  i2ptestnet = { config, pkgs, ... }: {
    boot.enableContainers = true;

    containers = {
      node1 = import ./machines/node/configuration.nix;
      node2 = import ./machines/node/configuration.nix;
    };
  };
}
