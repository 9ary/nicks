{ config, pkgs, ... }:

{
  config = {
    services.mpd = {
      enable = true;
      musicDirectory = "/mnt/data/streetwalrus/music";

      network.startWhenNeeded = true;

      extraConfig = ''
        auto_update "yes"

        replaygain "album"
        replaygain_limit "no"

        audio_output {
          type "pipewire"
          name "pw_output"
        }
      '';
    };

    programs.ncmpcpp = {
      enable = true;

      settings = {
        user_interface = "alternative";
        seek_time = 5;
        media_library_primary_tag = "album_artist";
        media_library_albums_split_by_date = false;

        progressbar_look = "─╂─";
        main_window_color = "white";
        progressbar_color = "white";
        progressbar_elapsed_color = "white";
        alternative_ui_separator_color = "white";
        current_item_prefix = "$(16)$r";
      };

      bindings = [
        { key = "k"; command = "scroll_up"; }
        { key = "j"; command = "scroll_down"; }
        { key = "space"; command = [ "select_item" "scroll_down" ]; }
        { key = "ctrl-u"; command = "page_up"; }
        { key = "ctrl-d"; command = "page_down"; }
        { key = "g"; command = "move_home"; }
        { key = "G"; command = "move_end"; }
        { key = "d"; command = "delete_playlist_items"; }
        { key = "d"; command = "delete_browser_items"; }
        { key = "d"; command = "delete_stored_playlist"; }
        { key = "l"; command = "next_column"; }
        { key = "l"; command = "slave_screen"; }
        { key = "h"; command = "previous_column"; }
        { key = "h"; command = "master_screen"; }
        { key = ";"; command = "execute_command"; }
        { key = "ctrl-n"; command = "next_screen"; }
        { key = "ctrl-p"; command = "previous_screen"; }
        { key = "L"; command = "next"; }
        { key = "H"; command = "previous"; }
        { key = "n"; command = "next_found_item"; }
        { key = "N"; command = "previous_found_item"; }
        { key = "K"; command = "move_sort_order_up"; }
        { key = "K"; command = "move_selected_items_up"; }
        { key = "J"; command = "move_sort_order_down"; }
        { key = "J"; command = "move_selected_items_down"; }
      ];
    };

    # TODO the home-manager config doesn't currently support command defs
    xdg.configFile."ncmpcpp/bindings".text = ''
      def_command "shuffle" [deferred]
        shuffle
    '';

    services.mpdris2 = {
      enable = true;
      package = pkgs.mpdris2.overrideAttrs (prev: {
        patches = prev.patches or [] ++ [
          ./mpd/0001-Add-optional-CD-like-previous-behavior.patch
        ];
      });
    };

    services.spotifyd = {
      enable = true;
      package = pkgs.pkgsUnstable.spotifyd.override {
        withMpris = true;
      };
      settings = {
        global = {
          backend = "pulseaudio";
          bitrate = 320;
          volume_normalisation = true;
          normalisation_pregain = 0;
          cache_path = "${config.xdg.dataHome}/spotifyd";
          no_audio_cache = true;
          zeroconf_port = 4444;
          use_mpris = true;
        };
      };
    };

    services.playerctld = {
      enable = true;
    };

    wayland.windowManager.sway.config.keybindings = {
      "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
      "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
      "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
      "XF86Tools" = "exec " + config.miscAttrs.terminal {
        command = "ncmpcpp";
        modal = true;
        size = { w = 120; h = 60; };
      };
    };
  };
}
