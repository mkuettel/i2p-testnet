{ config, pkgs, ... }:

{
  imports = [
    ../base/configuration.nix
  ];
  environment.systemPackages = with pkgs; [ i2p-tools ];
}
