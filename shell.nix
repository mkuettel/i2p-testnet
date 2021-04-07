let
  nixpkgs = import ./nixpkgs.nix;
  pkgs = import nixpkgs { config = {}; };
in
pkgs.mkShell {

  buildInputs = [ pkgs.nixops ];

  shellHook = ''
    export NIX_PATH="nixpkgs=${nixpkgs}:."
  '';

}
