{ lib, osConfig, pkgs, ... }:

{
  config = lib.mkIf osConfig.systemProfile.isWorkstation (let
    keybindsPath = ".local/share/TelegramDesktop/tdata/shortcuts-custom.json";
  in {
    home.packages = [ pkgs.pkgsUnstable.tdesktop ];

    home.file."${keybindsPath}".text = builtins.toJSON (lib.mapAttrsToList (k: v: {
      command = v;
      keys = k;
    }) {
      "ctrl+q" = null;
      "ctrl+w" = null;
      "ctrl+n" = "next_chat";
      "ctrl+p" = "previous_chat";
    });
  });
}
