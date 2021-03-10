{
  createVirtualHost = domain: listenaddr: root: {
    "${domain}" =  {
      http2 = true;
      listen = { addr = listenaddr; port = 80; ssl = false; };
      forceSSL = false;
      onlySSL = false;
      enableACME = false;
      inherit root;
      #  tryFiles = 
      locations."/" = {
      };
    };
  };
}
