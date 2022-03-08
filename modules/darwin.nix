{ pkgs, ... }:

{
  imports = import ./darwin-module-list.nix ++ [
    "${pkgs.sources.home-manager.src}/nix-darwin"
  ];
}

