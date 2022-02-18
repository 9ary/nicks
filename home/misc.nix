{ pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      git
      firefox
      unstable.neovim
      unstable.tdesktop
      wget
    ];
  };
}
