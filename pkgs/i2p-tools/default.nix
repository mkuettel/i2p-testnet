{ stdenv, lib, buildGoPackage, fetchgit }:

buildGoPackage rec {
  pname = "i2p-tools";
  version = "0.9.0";

  goPackagePath = "codeberg.org/diva.exchange/i2p-reseed";

  src = fetchgit {
    url = "https://codeberg.org/diva.exchange/i2p-reseed.git";
    rev = "v${version}-v2.36.0";
    sha256 = "08gxh1vgs4ihqggmqfv43118v8hf914lvmafwakm6hqc9i2dwg7r";
  };

  preConfigure = ''
    cd $NIX_BUILD_TOP
    rm -rf $sourceRoot/src/i2p-tools/vendor
  '';

  goDeps = ./deps.nix;
  preBuild = ''
    export GOPATH=$NIX_BUILD_TOP/go/src/${goPackagePath}:$GOPATH
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/diva.exchange/i2p-reseed";
    description = "Tools to supplement i2p (go version)";
    license = licenses.agpl3;
    maintainers = with maintainers; [ Mogria ];
  };
}
