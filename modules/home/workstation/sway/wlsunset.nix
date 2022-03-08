{ lib, osConfig, ... }:

{
  config = lib.mkIf osConfig.systemProfile.isWorkstation {
    services.wlsunset = {
      enable = true;
      latitude = "32";
      longitude = "35";
      temperature.night = 3400;
    };
  };
}
