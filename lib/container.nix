rec {

  commonSettings = {
    autoStart = true;
    ephemeral = true;

    # don't share interfaces with the host
    # give the containers an own network interface, so the containers don't bind 
    # on ports on the host
    privateNetwork = true;
    additionalCapabilities = [ "CAP_NET_ADMIN" "CAP_MKNOD"];
  };

  mkNode = testNetConfig: nodeConfig: rec {
    config = import ../machines/node/configuration.nix { inherit nodeConfig; inherit testNetConfig; };

    extraFlags = [
      "--network-veth"
    ];
    # rebuild container from scratch (more reproducability, but takes longer to start tests)
    # bindMounts = {
    #     "/home/i2p"
    # };
    # extraVeths = {
    #   "${nodeConfig.interfaceName}" = {
    #     localAddress = nodeConfig.localAddress6;
    #     hostAddress = nodeConfig.hostAddress6;
    #   };
    # };

    # hostBridge = "br${builtins.toString nodeConfig.id}";

    # hostAddress = nodeConfig.hostAddress;
    # localAddress = nodeConfig.localAddress;
    # hostAddress6 = nodeConfig.hostAddress6;
    # localAddress6 = nodeConfig.localAddress6;
    # interfaces = [ nodeConfig.interfaceName ];
  } // commonSettings;

  mkReseederNode = testNetConfig: {
      config = import ../machines/seeder/configuration.nix;

      # extraVeths = {
      #   "v-host" = {
      #     localAddress = "10.23.0.100/16";
      #     inherit hostAddress;
      #   };
      # };
      #
      # localAddress = "10.23.0.100/16";
      # localAddress = "10.0.0.2/8";
      # hostAddress = "10.0.0.1";
      # hostBridge = "br0";
      # inherit hostAddress;
  } // commonSettings;
}
