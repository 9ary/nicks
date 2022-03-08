{ pkgs, ... }:

{
  imports = import ./module-list.nix ++ [
    "${pkgs.sources.home-manager.src}/nixos"
  ];
}
