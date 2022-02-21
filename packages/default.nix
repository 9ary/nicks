{ pkgs, ... }:

let
  localPackages = {
    gitprompt-rs = pkgs.callPackage ./gitprompt-rs {};
  };
in {
  config = {
    nixpkgs.overlays = [
      (_: _: {
        local = localPackages;
      })
    ];
  };
}
