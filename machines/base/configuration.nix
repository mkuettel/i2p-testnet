{ config, pkgs, ... }:

{
  imports = [
    ../../mypkgs.nix
  ];

  networking.enableIPv6 = false;

  networking = {

    interfaces.eth0.tempAddress = "disabled";
    firewall = {
       # enable = false; # breaks if disabled
    };

    # disable dhcp client
    dhcpcd.enable = false;

  };

  # we need no DNS
  # glibc DNS will still work tough
  # services.nscd.enable = false; # doesn't work is required by systemd

}
