{ systemProfile, lib, ... }:

{
  imports = lib.optionals systemProfile.isWorkstation (import ./module-list.nix);
}
