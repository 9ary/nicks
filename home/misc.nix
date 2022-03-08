{ pkgs, ... }:

{
  config = {
    home.packages = [
      pkgs.git
      pkgs.firefox
      pkgs.pkgsUnstable.neovim
      pkgs.wget
      pkgs.tree
      pkgs.ripgrep

      pkgs.terminus_font
      pkgs.ubuntu_font_family
    ];
  };
}
