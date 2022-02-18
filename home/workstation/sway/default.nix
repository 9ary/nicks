{ config, pkgs, ... }:

{
  config = {
    wayland.windowManager.sway = {
      enable = true;
      package = let
        cfg = config.wayland.windowManager.sway;
      in pkgs.unstable.sway.override {
        extraSessionCommands = cfg.extraSessionCommands;
        extraOptions = cfg.extraOptions;
        withBaseWrapper = cfg.wrapperFeatures.base;
        withGtkWrapper = cfg.wrapperFeatures.gtk;
      };

      config = let
        cfg = config.wayland.windowManager.sway.config;
        color_theme = import ../../colors.nix;
      in {
        focus = {
          followMouse = "no";
          newWindow = "urgent";
        };
        seat."*".hide_cursor = "2000";

        input = {
          "type:keyboard" = {
            xkb_layout = "us,il";
            xkb_options = "grp:menu_toggle";
          };
          "type:pointer" = {
            accel_profile = "flat";
          };
          "type:touchpad" = {
            click_method = "clickfinger";
            natural_scroll = "enabled";
            tap = "enabled";
            dwt = "disabled";
          };
          "1386:890:Wacom_One_by_Wacom_S_Pen" = {
            map_from_region = ".0x.1 1x1";
          };
        };

        window = {
          titlebar = false;
          border = 4;
          commands = [
            {
              command = "fullscreen disable";
              criteria = {
                app_id = "^telegramdesktop$";
                title = "^Media viewer";
              };
            }
            {
              command = "move scratchpad";
              criteria = {
                app_id = "^firefox";
                title = " — Sharing Indicator$";
              };
            }
            {
              command = "move scratchpad";
              criteria = {
                title = " is sharing (your screen|a window)\.$";
              };
            }
          ];
        };

        floating = {
          titlebar = true;
          border = cfg.window.border;
          criteria = [
            { app_id = "modalterm"; }
          ];
        };

        colors = let
          colorSet = border: text: {
            border = border;
            background = border;
            text = text;
            indicator = border;
            childBorder = border;
          };
        in {
          focused = colorSet color_theme.blue color_theme.bg_1;
          focusedInactive = colorSet color_theme.fg_0 color_theme.bg_0;
          unfocused = colorSet color_theme.bg_2 color_theme.dim_0;
          urgent = colorSet color_theme.red color_theme.bg_1;
        };

        # TODO change to Mod4
        modifier = "Mod1";
      };
    };
  };
}
