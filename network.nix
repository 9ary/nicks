{
  "Akatsuki" = { config, pkgs, lib, ... }: {
    imports = [
      ./hosts/Akatsuki/configuration.nix
    ];

    config = {
      deployment.targetHost = "Akatsuki.lan";
    };
  };
}
