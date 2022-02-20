{ lib, ... }:

{
  options.systemProfile = {
    isWorkstation = lib.mkEnableOption "common configuration for workstations";
  };
}
