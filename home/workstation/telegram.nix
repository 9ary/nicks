{ lib, pkgs, ... }:

{
  config = let
    keybindsPath = ".local/share/TelegramDesktop/tdata/shortcuts-custom.json";
  in {
    home.packages = [ pkgs.unstable.tdesktop ];

    home.file."${keybindsPath}".text = builtins.toJSON (lib.mapAttrsToList (k: v: {
      command = v;
      keys = k;
    }) {
      "ctrl+q" = null;
      "ctrl+w" = null;
      "ctrl+n" = "next_chat";
      "ctrl+p" = "previous_chat";
    });
  };
}
