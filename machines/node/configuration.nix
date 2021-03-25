{ config, pkgs, ... }:

{
  imports = [
    ../../services/i2pd/i2p.nix
    ../../services/nginx/nginx.nix
  ];
}
