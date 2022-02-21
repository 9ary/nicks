{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.systemProfile.isWorkstation {
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    nixpkgs.overlays = [
      (_: _: {
        sway = pkgs.unstable.sway;
      })
    ];
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [ swaylock swayidle ];
    };
  };
}
