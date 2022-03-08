{ lib, osConfig, pkgs, ... }:

{
  config = lib.mkIf osConfig.systemProfile.isWorkstation {
    xsession.pointerCursor = {
      package = pkgs.gnome.gnome_themes_standard;
      name = "Adwaita";
      size = 32;
    };
  };
}
