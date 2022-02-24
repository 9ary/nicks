{ pkgs, ... }:

let
  localPackages = {
    gitprompt-rs = pkgs.callPackage ./gitprompt-rs {};
    python-pyalsaaudio = pkgs.callPackage ./python/pyalsaaudio.nix {};
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
