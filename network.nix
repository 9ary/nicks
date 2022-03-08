let
  sources = import ./sources.nix;
  nixpkgs = sources.nixpkgs.default;
in {
  network.pkgs = nixpkgs;
  network.specialArgs = {
    lib = nixpkgs.lib;
    pkgs = nixpkgs;
    sources = sources;
  };
} // builtins.mapAttrs (machineName: module: {
  imports = [
    ./modules
    module
  ];
}) {
  "Akatsuki" = { config, lib, ... }: {
    config = {
      deployment.targetHost = "Akatsuki.lan";
      networking.hostName = "Akatsuki";
      networking.hostId = "39745438";
    };
  };
}
