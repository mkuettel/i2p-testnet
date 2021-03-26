{
  mkConfig = id: rec {
    inherit id;
    name = "i2p-${builtins.toString id}";
    ifname = "ve-${name}";
  } // (let
      hostsPerSegment = 254;
      addressNr = id * 2;
      segmentNr = addressNr / hostsPerSegment;
      # plus 1 here so the nodes start at address 10.23.*1*.1
      # and doesn't conflict with the reseeder
      segment3 = builtins.toString (segmentNr + 1);
      segment4host = builtins.toString (addressNr - (segmentNr * hostsPerSegment));
      segment4local = builtins.toString (addressNr - (segmentNr * hostsPerSegment));
    in {
      hostAddress = "192.168.${segment3}.${segment4host}";
      localAddress = "192.168.${segment3}.${segment4local}";
  });
}
