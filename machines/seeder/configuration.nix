{ config, pkgs, ... }:

{
  imports = [
    ../base/configuration.nix
    ../../services/i2p-reseed/default.nix
  ];

  environment.systemPackages = with pkgs; [ i2p-tools ];
}
