{ nodeConfig, testNetConfig }:

{ config, pkgs, lib, ... }:

{
  imports = [
    ../base/configuration.nix
    ../../services/nginx/nginx.nix
  ];

  networking = {
    enableIPv6 = true;

    # disable dhcp client
    dhcpcd.enable = false;

    # set the default gateway to the address
    # of the VM host for this container
    defaultGateway6 = {
      interface = "${nodeConfig.interfaceName}";
      address = nodeConfig.hostAddress6;
    };
    #
    interfaces."${nodeConfig.interfaceName}" = {
      # virtual = true;
      useDHCP = false;
      ipv6.addresses = [{
        address = nodeConfig.localAddress6;
        prefixLength = nodeConfig.prefixLength6;
      }];
    };
  };

  services.i2pd = {
    enable = true;

    logLevel = "warn";

    # don't no nat by pass (private isolate)
    nat = false;
    netid = 23;

    # address of this device
    # address = nodeConfig.hostAddress; # or localAddress??

    address = nodeConfig.localAddress6;

    enableIPv6 = true;
    enableIPv4 = false;

    ifname = nodeConfig.interfaceName;

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
    # family = "mognet";

    trust = {
      # family = # router familiy to trust for first hop
      # hidden = false; # enable router concealment
      # routers = [ ]; # only connect to listed routers
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

    reseed = {
      # file = ;
      # floodfill
      # urls
      verify = true;
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

  };
}
