{ config, lib, pkgs, ... }:

{
  imports = [
    ./wlsunset.nix
  ];

  config = {
    wayland.windowManager.sway = {
      enable = true;
      package = null;

      config = let
        cfg = config.wayland.windowManager.sway.config;
        color_theme = import ../../colors.nix;
      in {
        fonts = {
          names = [ "Terminus" ];
          size = 15.0;
        };

        focus = {
          followMouse = "no";
          newWindow = "urgent";
          forceWrapping = true;
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

        output = {
          "*" = {
            background = "~/.swaybg fill";
            subpixel = "none";
          };
          "Samsung Electric Company U32J59x HTPK700098" = {
            # Longer vblank to minimize flickering during memory reclocks
            modeline = "590.4 3840 3888 3920 4000 2160 2208 2216 2460 +HSync -VSync";
          };
        };

        bars = [
          {
            fonts = cfg.fonts;
            position = "bottom";
            extraConfig = ''
              separator_symbol " | "
              icon_theme ${config.gtk.iconTheme.name}
            '';
            statusCommand = toString (pkgs.writers.writePython3 "swaystatus" {
              libraries = with pkgs.python3Packages; [ pkgs.local.python-pyalsaaudio psutil soco ];
            } ./status/status.py);

            colors = let
              workspace = background: text: {
                border = background;
                background = background;
                text = text;
              };
            in {
              separator = color_theme.fg_0;
              background = color_theme.bg_1;
              statusline = color_theme.fg_0;
              focusedWorkspace = workspace color_theme.blue color_theme.bg_1;
              activeWorkspace = workspace color_theme.fg_0 color_theme.bg_0;
              inactiveWorkspace = workspace color_theme.bg_2 color_theme.fg_0;
              urgentWorkspace = workspace color_theme.red color_theme.bg_1;
            };
          }
        ];

        # TODO menu
        # TODO terminal

        defaultWorkspace = "workspace number 1";
        modifier = "Mod4";
        bindkeysToCode = true;
        keybindings = let
          mapKeys = keys: names: mod: action: builtins.listToAttrs (
            lib.zipListsWith (key: name: {
              name = "${mod}+${key}";
              value = "${action} ${name}";
            }) keys names);

          dirKeys = [ "h" "j" "k" "l" ];
          dirNames = [ "left" "down" "up" "right" ];
          mapDirs = mapKeys (dirKeys ++ dirNames) (dirNames ++ dirNames);

          workspaceKeys = (builtins.genList (n: toString (n + 1)) 9) ++ [ "0" "n" "p" ];
          workspaceNames = (builtins.genList (n: "number ${toString (n + 1)}") 10) ++ [ "next_on_output" "prev_on_output"];
          mapWorkspaces = mapKeys workspaceKeys workspaceNames;

          volumeKeys = [ "XF86AudioRaiseVolume" "XF86AudioLowerVolume" "XF86AudioMute" ];
          volumeActions = map (a: "exec ${pkgs.pulseaudio}/bin/pactl ${a}") [
            "set-sink-volume @DEFAULT_SINK@ +5%"
            "set-sink-volume @DEFAULT_SINK@ -5%"
            "set-sink-mute @DEFAULT_SINK@ toggle"
          ];
          sonosCommand = a: "exec ${pkgs.netcat}/bin/nc -NU /run/user/$UID/sonos_volume <<< ${a}";
          sonosActions = map sonosCommand [ "+" "-" "x" "l" ];
        in lib.mkMerge [
          (mapDirs "${cfg.modifier}" "focus")
          (mapDirs "${cfg.modifier}+Shift" "move")
          (mapWorkspaces "${cfg.modifier}" "workspace")
          (mapWorkspaces "${cfg.modifier}+Shift" "move container to workspace")
          (mapDirs "${cfg.modifier}+Ctrl" "move workspace to output")
          (mapKeys volumeKeys volumeActions "" "")
          (mapKeys (volumeKeys ++ [ "XF86AudioPlay" ]) sonosActions "Shift" "")
          {
            "${cfg.modifier}+q" = "kill";

            "${cfg.modifier}+space" = "focus mode_toggle";
            "${cfg.modifier}+a" = "focus parent";
            "${cfg.modifier}+d" = "focus child";

            "${cfg.modifier}+semicolon" = "split h";
            "${cfg.modifier}+v" = "split v";
            "${cfg.modifier}+s" = "layout stacking";
            "${cfg.modifier}+w" = "layout tabbed";
            "${cfg.modifier}+e" = "layout toggle split";

            "${cfg.modifier}+f" = "fullscreen toggle";
            "${cfg.modifier}+Shift+space" = "floating toggle";

            "${cfg.modifier}+Escape" = "workspace back_and_forth";

            "${cfg.modifier}+Shift+c" = "reload";
            "${cfg.modifier}+Shift+q" = "exit";

            "${cfg.modifier}+Return" = "exec $TERMINAL";

            "XF86MonBrightnessUp" = "exec xbacklight -perceived -inc 5";
            "XF86MonBrightnessDown" = "exec xbacklight -perceived -dec 5";
          }
        ];
        modes = {};
      };

      extraConfig = ''
        titlebar_padding 5 1
        hide_edge_borders --i3 none
      '';
    };
  };
}
