{ stdenv, lib, mogi2pd, boost, openssl, zlib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "i2pd-tools";
  version = "0.1.0-master";

  # patches = [ ./i2pd-tools-Makefile.patch ];

  src = fetchFromGitHub {
    owner = "PurpleI2P";
    repo = "i2pd-tools";
    rev = "86234df388985ad096db79f964b036b063b45863";
    sha256 = "017ad1r7hj58pgj020d47x7rjcjpsj3impwl18yjh8ic5w7ia07f";
  };

  buildInputs = [ mogi2pd boost openssl zlib ];

  preBuild = ''
    substituteInPlace Makefile \
      --replace "I2PD_PATH = i2pd" "I2PD_PATH = ${mogi2pd}/bin/i2pd" \
      --replace "I2PD_LIB = libi2pd.a" "I2PD_LIB = ${mogi2pd}/lib/libi2pd.a"
  '';

  meta = with lib; {
    homepage = "https://gitea.com/gitea/tea";
    description = "Tools to supplement i2pd";
    license = licenses.bsd3;
    maintainers = with maintainers; [ Mogria ];
  };
}
