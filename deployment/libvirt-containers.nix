{
  i2ptestnet =
    { config, pkgs, ... }:
    {
      # required for serial console access via virsh
      boot.kernelParams = [ "console=ttyS0,115200" ];

      deployment = {
        targetEnv = "libvirtd";
        libvirtd = {
          # vmFlags = .... ; # arbitrary flags passed to modifyvm command
          memorySize = 2048; # megabytes
          vcpu = 2; # number of cpus
          headless = true;
          baseImageSize = 10; # gigabytes

          extraDevicesXML = ''
            <serial type='pty'>
              <target port='0'/>
            </serial>
            <console type='pty'>
              <target type='serial' port='0'/>
            </console>
          '';
        };
      };
    };
}
