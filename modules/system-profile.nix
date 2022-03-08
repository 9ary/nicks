{ lib, ... }:

{
  options.systemProfile = {
    isDusk = lib.mkEnableOption "common configuration for Dusk";
    isNovenary = lib.mkEnableOption "common configuration for novenary";
    isWorkstation = lib.mkEnableOption "common configuration for workstations";
  };
}
