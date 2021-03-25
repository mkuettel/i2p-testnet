{ config, pkgs, ... }:

{
  systemd.services.i2pd-reseed = {
    description = "I2P reseed server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig =
    {
      User = "nobody";
      Restart = "on-abort";
      ExecStart = "${pkgs.i2p-tools}/bin/i2p-tools reseed";
    };
  };
}
