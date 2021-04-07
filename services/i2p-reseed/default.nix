{ config, pkgs, ... }:

let
  home = "/var/lib/i2pd";
in {
  # reuse i2pd user here, because normally a node would also contain a reseeder
  # plus we get a good working directory /var/lib/i2pd
  users.users.i2pd = {
    group = "i2pd";
    description = "I2Pd Reseed User";
    inherit home;
    createHome = true;
    uid = config.ids.uids.i2pd;
  };

  users.groups.i2pd.gid = config.ids.gids.i2pd;

  systemd.services.i2pd-reseed = {
    description = "I2P reseed server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig =
    {
      User = "i2pd";
      Restart = "on-abort";
      WorkingDirectory = home;
      ExecStartPre = "-${pkgs.coreutils}/bin/mkdir ${home}/netDb";
      ExecStart = ''
        ${pkgs.i2p-tools}/bin/i2p-tools reseed \
          --netdb=${home}/netDb \
          --key "${pkgs.i2p-testnet-reseed-keys}/mkuettel_at_mail.i2p.pem" \
          --tlsCert "${pkgs.i2p-testnet-reseed-keys}/mkuettel_at_mail.i2p.crt" \
          --tlsKey "${pkgs.i2p-testnet-reseed-keys}/mkuettel_at_mail.i2p.crl" \
          --signer "mkuettel@mail.i2p"
      '';
    };
  };

  # the reseeder runs on this port
  networking.firewall.allowedTCPPorts = [ 8443 ];

  environment.systemPackages = [ pkgs.i2p-testnet-reseed-keys ];
}
