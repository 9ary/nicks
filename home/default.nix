{ lib, ... }:

{
  imports = import ./module-list.nix;

  options = {
    commonSettings = lib.mkOption {
      type = lib.types.attrs;
      description = "Settings shared by various parts of the configuration.";
    };
  };

  config = {
    home.stateVersion = "21.11";
  };
}
