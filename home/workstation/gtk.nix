{ pkgs, ... }:

{
  config = {
    gtk = {
      enable = true;
      font = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
        size = 12;
      };
      iconTheme = {
        package = pkgs.gnome.gnome_themes_standard;
        name = "Adwaita";
      };
      theme = {
        package = pkgs.gnome.gnome_themes_standard;
        name = "Adwaita";
      };
    };
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        cursor-theme = "Adwaita";
      };
    };
  };
}
