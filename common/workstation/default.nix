{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.systemProfile.isWorkstation {
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    nixpkgs.overlays = let
      unstable = import <unstable> {};
    in [
      (_: _: {
        sway = unstable.sway;
      })
    ];
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [ swaylock swayidle ];
    };
  };
}
