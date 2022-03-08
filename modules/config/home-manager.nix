{ lib, config, pkgs, ... }:

{
  config = {
    home-manager = {
      extraSpecialArgs = {
        inherit pkgs;
      };
      sharedModules = [
        ../home
      ];
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
