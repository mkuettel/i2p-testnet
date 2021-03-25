{ config, pkgs, ... }:

{
  imports = [
    ../../sevices/i2p-reseed
  ];
  environment.systemPackages = with pkgs; [ i2p-tools ];
}
