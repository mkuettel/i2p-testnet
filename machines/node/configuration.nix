{ nodeConfig, testNetConfig }:

{ config, pkgs, lib, ... }:

{
  imports = [
    ../base/configuration.nix
  ];

  networking = {

    # set the default gateway to the address
    # of the VM host for this container
    # defaultGateway = {
    #   interface = "eth0";
    #   address = nodeConfig.hostAddress;
    # };
    # defaultGateway6 = {
    #   interface = "${nodeConfig.interfaceName}";
    #   address = nodeConfig.hostAddress6;
    # };
    # #
    # interfaces."eth0" = {
    #   # virtual = true;
    #   useDHCP = false;
    #   ipv4.addresses = [{
    #     address = nodeConfig.localAddress;
    #     prefixLength = nodeConfig.netmask;
    #   }];
    # };
    # # these routes are added on the interface of the host
    # interfaces."${nodeConfig.interfaceName}" = {
    #   ipv4.routes = [{
    #     address = nodeConfig.hostAddress;
    #     prefixLength = nodeConfig.netmask;
    #   }];
    # };
    # interfaces."${nodeConfig.interfaceName}" = {
    #   # virtual = true;
    #   useDHCP = false;
    #   ipv6.addresses = [{
    #     address = nodeConfig.localAddress6;
    #     prefixLength = nodeConfig.prefixLength6;
    #   }];
    # };
  };

  services.i2pd = {
    enable = true;

    logLevel = "warn";

    # don't no nat by pass (private isolate)
    nat = false;
    netid = 23;

    # address of this device
    # address = nodeConfig.hostAddress; # or localAddress??

    address = nodeConfig.localAddress;

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
      urls = [ "http://10.23.0.2:8443/i2pseeds.su3"];
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
