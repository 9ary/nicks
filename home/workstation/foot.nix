{ config, lib, ... }:

{
  config = {
    programs.foot = {
      enable = true;
      settings = let
        color_theme = lib.mapAttrs (_: c: lib.removePrefix "#" c) (import ../colors.nix);
      in {
        main = {
          term = "xterm-256color";

          font = "Ubuntu Mono:size=17";
          dpi-aware = "no";
        };

        url = {
          osc8-underline = "always";
        };

        bell = {
          urgent = "yes";
        };

        scrollback = {
          lines = 10000;
        };

        cursor = {
          color = "${color_theme.bg_0} ${color_theme.br_cyan}";
        };

        colors = {
          background = color_theme.bg_0;
          foreground = color_theme.fg_0;

          regular0 = color_theme.bg_1;
          regular1 = color_theme.red;
          regular2 = color_theme.green;
          regular3 = color_theme.yellow;
          regular4 = color_theme.blue;
          regular5 = color_theme.magenta;
          regular6 = color_theme.cyan;
          regular7 = color_theme.dim_0;

          bright0 = color_theme.bg_2;
          bright1 = color_theme.br_red;
          bright2 = color_theme.br_green;
          bright3 = color_theme.br_yellow;
          bright4 = color_theme.br_blue;
          bright5 = color_theme.br_magenta;
          bright6 = color_theme.br_cyan;
          bright7 = color_theme.fg_1;
        };

        key-bindings = {
          show-urls-launch = "Control+i";
          spawn-terminal = "none";
        };
      };
    };
  };
}
