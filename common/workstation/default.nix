{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.systemProfile.isWorkstation {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

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

    hardware.acpilight.enable = true;
  };
}
