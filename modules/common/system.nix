# Basic system configuration
{ config, ... }:

{
  config = {
    nix.autoOptimiseStore = true;

    environment.pathsToLink = [
      "/share/zsh"
    ];

    services.openssh.enable = true;

    services.journald.extraConfig = ''
      SystemMaxUse=100M
      MaxFileSec=7day
    '';
  };
}
