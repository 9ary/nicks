{
  "Akatsuki" = { config, pkgs, lib, ... }: {
    imports = [
      ./hosts/Akatsuki/configuration.nix
    ];

    deployment.targetHost = "Akatsuki.lan";
  };
}
