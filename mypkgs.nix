{ config, pkgs, ... }: 

{
  # For now just use the stable channel for less breakage
  # TODO: pin this?
  nix.nixPath = [ "nixpkgs=https://nixos.org/channels/nixos-20.09/nixexprs.tar.xz" ];

  nixpkgs.overlays = [
    (self: super: rec {
      i2pd = super.callPackage ./pkgs/i2pd { };
      i2p-tools = super.callPackage ./pkgs/i2p-tools { };
    })
  ];
}
