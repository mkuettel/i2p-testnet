{ config, pkgs, ... }: 


{
  packageOverrides = super: let self = super.pkgs; in {
    i2pd = super.callPackage ./pkgs/i2pd/default.nix { };
    i2ptools = super.callPackage ./pkgs/i2p-tools { };
  };
}
