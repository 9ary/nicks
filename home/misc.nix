{ pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      git
      firefox
      unstable.neovim
      unstable.tdesktop
      wget
      tree
      ripgrep

      terminus_font
      ubuntu_font_family
    ];
  };
}
