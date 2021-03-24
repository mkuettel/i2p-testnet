{ config, pkgs, ... }:

let
  address = "192.168.1.3";
in {
 #networking.interfaces.eth0 = {
 #  ipv4 = {
 #    addresses = [ { inherit address; prefixLength = 24; } ];
 #  };
 #};
  services.i2pd = {
    enable = true;

    # address if this device
    inherit address;
    enableIPv6 = false;
    enableIPv4 = true;
    ifname = "eth0";

    # addressbook = {
      # defaulturl = 
      # subscriptions
    # };
    bandwidth = 100; # limit bandwidth in KBbs (if not set it's 32 KBps)
    share = 100; # amount of traffic to be transit traffic in %

    # dataDir = /var/i2pdata;
    exploratory = {
      inbound = {
        length = 3;
        quantity = 10;
      };
      outbound = {
        length = 3;
        quantity = 10;
      };
    };
    family = "mognet";

    trust = {
      # family = # router familiy to trust for first hop
      # hidden = false; # enable router concealment
      routers = [ ]; # only connect to listed routers
    };

    # uncomment if router is unrachable and needs introduction nodes
    # floodfill = true;

    # ifname = ;
    # ifname4 = ;
    # ifname6 = ;

    # serve something on I2P forward port
    inTunnels = {
      "mogeep" = {
        enable = true;
        # keys = "mogeep.dat";
        # accessList = []; # nodes allowed to connect
        inPort = 80;
        address = "127.0.0.1";
        destination = "127.0.0.1";
        port = 8081;
      };
    };

    #limits = {
    #  coreSize = ;
    #};
  };

  reseed = {
    # file = ;
    # floodfill
    # urls
    # verify
  };

  # upnp = {
  #   enable = false;
  #   name = "I2Pd";
  # };

  websocket = {
    # enable = true;
    address = "127.0.0.1";
    name = "websockets";
    port = 7666; #default
  };
}
