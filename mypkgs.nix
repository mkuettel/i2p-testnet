{ config, pkgs, ... }: 

{
  # For now just use the stable channel for less breakage
  # TODO: pin this?
  # nix.nixPath = [ "nixpkgs=https://github.com/NixOS/nixpkgs/archive/29363442f5e6b14d3f2fdfd5f13605a47bd02301.tar.gz" ];

  # replace the nixos containers module with my own version to fix networking
  disabledModules = [ "virtualisation/nixos-containers.nix" ];
  imports = [ ./modules/nixos-containers.nix ];

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
