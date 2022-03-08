{ lib, config, ... }:

{
  config = lib.mkIf (config.networking.hostName == "Akatsuki") {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}
