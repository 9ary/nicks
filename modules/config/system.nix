# Basic system configuration
{ lib, config, ... }:

{
  config = lib.mkMerge [
    {
      nix.autoOptimiseStore = true;

      environment.pathsToLink = [
        "/share/zsh"
      ];

      services.openssh.enable = true;
    }
    (lib.mkIf config.systemProfile.isNovenary {
      services.journald.extraConfig = ''
        SystemMaxUse=100M
        MaxFileSec=7day
      '';
    })
  ];
}
