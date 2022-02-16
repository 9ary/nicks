{ pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      git
      firefox
      neovim
      tdesktop
      wget
    ];
  };
}
