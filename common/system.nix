# Basic system configuration
{ ... }:

{
  config = {
    nixpkgs.overlays = [
      (_: _: {
        unstable = import <unstable> {};
      })
    ];

    nix.autoOptimiseStore = true;

    services.openssh.enable = true;

    services.journald.extraConfig = ''
      SystemMaxUse=100M
      MaxFileSec=7day
    '';
  };
}
