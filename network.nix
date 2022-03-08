let
  sources = import ./sources.nix;
  nixpkgs = sources.nixpkgs.default;
in {
  network.pkgs = nixpkgs;
  network.specialArgs = {
    lib = nixpkgs.lib;
    pkgs = nixpkgs;
  };
} // builtins.mapAttrs (machineName: module: {
  imports = [
    ./modules
    module
  ];
}) {
  "Akatsuki" = { config, lib, ... }: {
    imports = [
      ./modules/hosts/Akatsuki/configuration.nix
    ];

    config = {
      deployment.targetHost = "Akatsuki.lan";
    };
  };
}
