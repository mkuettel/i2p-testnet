{ config, pkgs, ... }:

{
  imports = [
    ../../mypkgs.nix
  ];

  networking.enableIPv6 = true;
}
