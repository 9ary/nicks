# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "zroot/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B8CA-6D6E";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    { device = "zroot/nixos/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "zroot/userdata/home";
      fsType = "zfs";
    };

  fileSystems."/mnt/data" =
    { device = "/dev/disk/by-uuid/7aec7f58-44b4-4737-bd62-3dad9effa696";
      fsType = "btrfs";
      options = [ "noauto" "x-systemd.automount" "rw" "noatime" "compress-force=zstd" "subvol=data" ];
    };

  fileSystems."/mnt/oldarch" =
    { device = "zroot/oldarch/root";
      fsType = "zfs";
    };

  fileSystems."/mnt/oldarch/home" =
    { device = "zroot/oldarch/home";
      fsType = "zfs";
    };

  fileSystems."/mnt/oldarch/mnt/games" =
    { device = "zroot/oldarch/games";
      fsType = "zfs";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/fde373ce-ffc1-4dcb-9476-fa4e5bac26b8"; }
    ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}