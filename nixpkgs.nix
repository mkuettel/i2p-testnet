let
  commitRev = "29363442f5e6b14d3f2fdfd5f13605a47bd02301"; # 18.03 on 2020-01-22
in builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${commitRev}.tar.gz";
  sha256 = "1dfk3q1q2w53k3zl9biijgpr1zvj5xr673p15a7rh1d11sadrxjh";
}
