{ config, pkgs, ... }:

{
  imports = [
    ../../nixpkgs.nix
    ../../services/i2pd/i2p.nix
    ../../services/nginx/nginx.nix
  ];

}
