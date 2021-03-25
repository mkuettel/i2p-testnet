{
  i2ptestnet =
    { config, pkgs, ... }:
    {
      deployment = {
        targetEnv = "virtualbox";
        virtualbox = {
          # vmFlags = .... ; # arbitrary flags passed to modifyvm command
          memorySize = 2048; # megabytes
          vcpu = 2; # number of cpus
          headless = true;
          # sharedFolders = {
          #   hostPath = "/var/i2p-testnet";
          #   readOnly = true;
          # };
        };
      };
    };
}
