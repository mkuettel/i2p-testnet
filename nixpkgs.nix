{ config, pkgs, ... }: 

{
  nixpkgs.overlays = [
    (self: super: rec {
      i2pd = super.callPackage ./pkgs/i2pd { };
      i2p-tools = super.callPackage ./pkgs/i2p-tools { };
    })
  ];
}
