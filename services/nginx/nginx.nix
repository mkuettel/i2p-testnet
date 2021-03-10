{ pkgs, config, ... }:

{

  services.nginx = {
    enable = true;
    enableReload = true;
    # package = ;
    # appendConfig = '' '';
    # appendHttpConfig = '' '';

    recommendedTlsSettings = false;
    recommendedOptimisation = true;
    # recommendedProxySettings = true;

    # upstreams = 

    virtualHosts = {

    };
  };


}
