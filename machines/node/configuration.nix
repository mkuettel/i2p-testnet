{ config, pkgs, ... }:

{
  imports = [
    ../base/configuration.nix
    ../../services/i2pd/i2p.nix
    ../../services/nginx/nginx.nix
  ];
}
