{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common

    ./ddcci.nix
    ./jellyfin.nix
    ./metalfan.nix
    ./transmission.nix
  ];

  config = {
    boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.devNodes = "/dev/";

    services.zfs.trim.enable = true;
    # services.zfs.autoScrub.enable = true;
    # services.zfs.autoScrub.pools = [ "rpool" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "Akatsuki"; # Define your hostname.
    networking.hostId = "39745438";

    time.timeZone = "Asia/Jerusalem";

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      keyMap = "us";
    };

    systemProfile = {
      isWorkstation = true;
    };

    networking.firewall = {
      allowedTCPPorts = [
        # Sonos/SoCo
        # TODO move Sonos volume control to a system module?
        1400

        # spotifyd
        4444
      ];
      allowedUDPPorts = [
        # mDNS/spotifyd
        5353
      ];
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "21.11"; # Did you read the comment?
  };
}
