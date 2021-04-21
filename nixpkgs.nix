let
  commitRev = "59763ff16abbcc2e13a8fb04f4e4cd33f40db843"; # 20.09 on 2021-04-14
in builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${commitRev}.tar.gz";
  sha256 = "1as7bhs2d31rws0s6b6rfw30kyvh7klfqfgf0r3jkhfj312qaqlr";
}
