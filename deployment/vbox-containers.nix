{
  i2ptestnet =
    { config, pkgs, ... }:
    { deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 2048; # megabytes
      deployment.virtualbox.vcpu = 2; # number of cpus
    };
}
