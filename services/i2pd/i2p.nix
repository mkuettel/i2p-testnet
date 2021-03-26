{ config, pkgs, ... }:

let
  address = "192.168.1.3";
in {
 #networking.interfaces.eth0 = {
 #  ipv4 = {
 #    addresses = [ { inherit address; prefixLength = 24; } ];
 #  };
 #};

}
