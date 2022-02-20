{ config, lib, ... }:

{
  config = lib.mkIf config.systemProfile.isWorkstation {
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    hardware.opengl.enable = true;
  };
}
