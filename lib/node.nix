let 
  lib = import <nixpkgs/lib>;
in {
  mkConfig = id: rec {
    inherit id;
    name = "i2p-${builtins.toString id}";
    interfaceName = "ve-${name}";
  } // (let
      hostsPerSegment = 254;
      addressNr = id * 2;
      segmentNr = addressNr / hostsPerSegment;
      # plus 1 here so the nodes start at address 10.23.*1*.1
      # and doesn't conflict with the reseeder
      segment3 = builtins.toString (segmentNr + 1);
      segment4host = builtins.toString (addressNr - (segmentNr * hostsPerSegment));
      segment4local = builtins.toString (addressNr + 1 - (segmentNr * hostsPerSegment));
    in {
      # hostAddress = "10.23.${segment3}.${segment4host}";
      # localAddress = "10.23.${segment3}.${segment4local}";
      # netmask = "8";

      networkAddress6 = "fdb9:7509:b9ad:${lib.trivial.toHexString id}::";
      hostAddress6 = "fdb9:7509:b9ad:${lib.trivial.toHexString id}::1";
      localAddress6 = "fdb9:7509:b9ad:${lib.trivial.toHexString id}::2";
      prefixLength6 = 64;
  });
}
