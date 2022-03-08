{ lib, ... }:

{
  options.systemProfile = {
    isNovenary = lib.mkEnableOption "common configuration for novenary";
    isWorkstation = lib.mkEnableOption "common configuration for workstations";
  };
}
