{ lib, nixosConfig, ... }:

let
  hostModule = ./. + "/${nixosConfig.networking.hostName}";
in {
  imports = lib.optionals (builtins.pathExists hostModule) [ hostModule ];
}
