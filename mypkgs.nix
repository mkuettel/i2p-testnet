{ config, pkgs, ... }: 

{
  # For now just use the stable channel for less breakage
  # TODO: pin this?
  nix.nixPath = [ "nixpkgs=https://nixos.org/channels/nixos-20.09/nixexprs.tar.xz" ];

  nixpkgs.overlays = [
    (self: super: rec {
      i2pd = super.callPackage ./pkgs/i2pd { };
      i2p-tools = super.callPackage ./pkgs/i2p-tools { };
      i2p-testnet-reseed-keys = super.stdenv.mkDerivation rec {
        pname = "i2p-testnet-reseed-keys";
        version = "0.0.1";
        src = ./keys/su3;
        installPhase = ''
          mkdir $out
          cp $src/mkuettel_at_mail.* $out
        '';


      };
    })
  ];
}
