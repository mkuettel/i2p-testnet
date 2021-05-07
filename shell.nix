let
  nixpkgs = import ./nixpkgs.nix;
  pkgs = import nixpkgs { config = {}; };
in
pkgs.mkShell {

  buildInputs = with pkgs; [
    nixops
    docker-compose
    moreutils
    bats
    jq
  ] ++ (with python38Packages; [
    python
    pylint
  ]);

  shellHook = ''
    export NIX_PATH="nixpkgs=${nixpkgs}:."
  '';

}
