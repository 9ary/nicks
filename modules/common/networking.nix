{ ... }:

{
  config = {
    networking.useDHCP = false;
    networking.useNetworkd = true;

    systemd.network.networks."50-wired" = {
      matchConfig.Name = [ "en*" ];
      DHCP = "yes";
      dhcpV4Config = {
        UseDomains = true;
        RouteMetric = 20;
      };
    };

    services.resolved = {
      enable = true;
      dnssec = "false";
    };
  };
}
