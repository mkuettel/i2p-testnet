let 
  lib = import <nixpkgs/lib>;
in {
  mkConfig = id: rec {
    inherit id;
    name = "i2p-${builtins.toString id}";
    interfaceName = "ve-${name}";
  } // (let
      hostsPerSegment = 256;
      addressNr = id * 4;
      segmentNr = addressNr / hostsPerSegment;
      # plus 1 here so the nodes start at address 10.23.*1*.1
      # and doesn't conflict with the reseeder
      segment3 = builtins.toString (segmentNr + 1);
      segment4network = builtins.toString (addressNr - (segmentNr * hostsPerSegment) - 4);
      segment4host = builtins.toString (addressNr - (segmentNr * hostsPerSegment) - 3);
      segment4local = builtins.toString (addressNr - (segmentNr * hostsPerSegment) - 2);
    in {
      hostAddress = "10.23.${segment3}.${segment4host}";
      localAddress = "10.23.${segment3}.${segment4local}";
      networkAddress =  "10.23.${segment3}.${segment4network}";
      networkPrefix = "30";

      # networkAddress6 = "fdb9:7509:b9ad::${lib.trivial.toHexString id}:0/64";
      # hostAddress6 = "fdb9:7509:b9ad::${lib.trivial.toHexString id}:1";
      # localAddress6 = "fdb9:7509:b9ad::${lib.trivial.toHexString id}:2";
      # prefixLength6 = 64;
  });
}
