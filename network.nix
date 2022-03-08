let
  sources = import ./sources.nix;
  nixpkgs = sources.nixpkgs.default;

  extendNetworkMachineModule = module: { extendModules, ... }:
    let extendedModule = extendModules {
      modules = [
        {
          config = {
            _module.args = {
              lib = nixpkgs.lib.mkForce nixpkgs.lib;
              pkgs = nixpkgs.lib.mkForce nixpkgs;
            };
          };
        }
        module
      ];
      specialArgs = {
        lib = nixpkgs.lib;
        pkgs = nixpkgs;
      };
    }; in { inherit (extendedModule) options config; };
in {
  network.pkgs = nixpkgs;
} // builtins.mapAttrs (machineName: extendNetworkMachineModule) {
  "Akatsuki" = { config, lib, ... }: {
    imports = [
      ./hosts/Akatsuki/configuration.nix
    ];

    config = {
      deployment.targetHost = "Akatsuki.lan";
    };
  };
}
