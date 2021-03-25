{ config, pkgs, ... }: 

{
  nixpkgs.overlays = [
    (self: super: rec {
      mogi2pd = super.callPackage ./pkgs/i2pd { };
      i2p-tools = super.callPackage ./pkgs/i2p-tools {
        inherit mogi2pd;
      };
    })
  ];
}
