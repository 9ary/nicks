{ config, lib, pkgs, ... }:

let
  cfg = config.services.metalfan;

  script = pkgs.writers.writePython3 "metalfan.py" {
    libraries = let pyPkgs = pkgs.python3Packages; in [ pyPkgs.attrs ];
  } ./metalfan.py;

  configFile = pkgs.writeText "metalfan.json" (builtins.toJSON cfg.config);
in {
  options.services.metalfan = {
    enable = lib.mkEnableOption "metalfan - a fan control script";

    config = lib.mkOption {
      default = {
        hwmons = {};
        fangroups = [];
      };
      description = "Contents of the config file.";
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.metalfan = {
      description = "Fan control script";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${script} ${configFile}";
      };
    };
  };
}
