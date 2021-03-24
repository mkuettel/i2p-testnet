{ region ? "us-west-2" # defaults to us-west-2
, ec2defaults ? import <mychannel/utils/ec2/defaults> {}
let

  backend =
    { config, pkgs, region, zone, keyId, ec2defaults, ... }:
    {
    };

in

{
  network.description = "Service backends";

  backend0 = backend { inherit ec2defaults region; zone = "${region}a"; };
  backend1 = backend { inherit ec2defaults region; zone = "${region}b"; };
  backend2 = backend { inherit ec2defaults region; zone = "${region}c"; };
}
