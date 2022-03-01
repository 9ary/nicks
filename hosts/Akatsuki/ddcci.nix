{ config, pkgs, ... }:

{
  config = {
    boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
    boot.kernelModules = [ "ddcci" ];
    services.udev.extraRules = ''
      # Reload ddcci driver on monitor hotplug (since the driver doesn't handle it)
      SUBSYSTEM=="drm", ACTION=="change", \
        RUN+="${pkgs.bash}/bin/sh -c 'rmmod ddcci_backlight ddcci; sleep 5; modprobe ddcci'"
    '';
  };
}
