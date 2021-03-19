{ stdenv, fetchFromGitHub
, boost, zlib, openssl
, upnpSupport ? true, miniupnpc ? null
, aesniSupport ? stdenv.hostPlatform.aesSupport
, avxSupport   ? stdenv.hostPlatform.avxSupport
}:

assert upnpSupport -> miniupnpc != null;

stdenv.mkDerivation rec {
  pname = "i2pd";
  version = "2.35.0";

  src = fetchgit {
    url = "https://codeberg.org/diva.exchange/i2p.git";
    rev = version;
    sha256 = "1qnrwx94329rvf709mwqkh4n4f9320l1gm3b4vj1i2naaqammj88";
  };

  buildInputs = with stdenv.lib; [ boost zlib openssl ]
    ++ optional upnpSupport miniupnpc;
  makeFlags =
    let ynf = a: b: a + "=" + (if b then "yes" else "no"); in
    [ (ynf "USE_AESNI" aesniSupport)
      (ynf "USE_AVX"   avxSupport)
      (ynf "USE_UPNP"  upnpSupport)
    ];

  installPhase = ''
    install -D i2pd $out/bin/i2pd
  '';

  meta = with stdenv.lib; {
    homepage = "https://i2pd.website";
    description = "Minimal I2P router written in C++, with custom configuration";
    license = licenses.bsd3;
    maintainers = with maintainers; [ edwtjo ];
    platforms = platforms.linux;
  };
}
