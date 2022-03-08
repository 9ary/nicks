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
    ./modules/darwin.nix
    module
  ];
}) {
  "DUBANKS-M-9ATM" = { lib, config, ... }: {
    config = {
      deployment.targetHost = "DUBANKS-M-9ATM.local";
      networking.hostName = "DUBANKS-M-9ATM";
      networking.hostId = "0f0d043d";
    };
  };
}
