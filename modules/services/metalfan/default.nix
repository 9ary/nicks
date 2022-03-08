{ lib, config, pkgs, ... }:

let
  cfg = config.services.metalfan;

  script = pkgs.writers.writePython3 "metalfan.py" {
    libraries = let pyPkgs = pkgs.python3Packages; in [ pyPkgs.attrs ];
  } ./metalfan.py;
in {
  options = {
    services.metalfan = {
      enable = lib.mkEnableOption "metalfan - a fan control script";

      config = lib.mkOption {
        default = {
          hwmons = {};
          fangroups = [];
        };
        description = "Contents of the config file.";
        type = lib.nullOr lib.types.attrs;
      };

      configFile = lib.mkOption {
        description = "The config file.";
        type = lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.metalfan = {
      configFile = lib.mkIf (cfg.config != null)
        (pkgs.writeText "metalfan.json" (builtins.toJSON cfg.config));
    };

    systemd.services.metalfan = {
      description = "Fan control script";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${script} ${toString cfg.configFile}";
      };
    };
  };
}
