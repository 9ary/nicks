# Basic system configuration

{ ... }:

{
  nix.autoOptimiseStore = true;

  services.openssh.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    MaxFileSec=7day
  '';
}
