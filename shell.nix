let sources = import ./sources.nix; in
{ pkgs ? sources.nixpkgs.default
}:

let
  linkFarm' = name: entries: pkgs.runCommand name {
    preferLocalBuild = true;
    allowSubstitutes = false;
  } ''
    mkdir -p "$out"
    cd "$out"
    ${pkgs.lib.concatMapStrings (entry: ''
      mkdir -p -- "$(dirname -- ${pkgs.lib.escapeShellArg entry.subPath})"
      ln -s -- ${pkgs.lib.escapeShellArg entry.path} ${pkgs.lib.escapeShellArg entry.subPath}
    '') entries}
  '';

  pkgsDarwin = pkgs.pkgsDarwin;
  darwin-config = ./modules/hosts/DUBANKS-M-9ATM/darwin-configuration.nix;
  nix-darwin = let
    src = pkgsDarwin.sources.nix-darwin.src;
  in pkgsDarwin.writeText "nix-darwin-default.nix" ''
    { sources ? import ${toString ./sources.nix}
    , nixpkgs ? toString sources.nixpkgs.darwin.path
    , configuration ? ${toString darwin-config}
    , lib ? pkgs.lib
    , pkgs ? sources.nixpkgs.darwin
    , system ? "x86_64-darwin"
    }:

    let
      evalConfig = import ${toString src}/eval-config.nix { inherit lib; };

      eval = evalConfig {
        inherit pkgs system;
        modules = [ configuration ];
        inputs = { inherit nixpkgs; };
        specialArgs = {
          inherit lib pkgs sources;
        };
      };

      # The source code of this repo needed by the [un]installers.
      nix-darwin = lib.cleanSource (
        lib.cleanSourceWith {
          # We explicitly specify a name here otherwise `cleanSource` will use the
          # basename of ./.  which might be different for different clones of this
          # repo leading to non-reproducible outputs.
          name = "nix-darwin";
          src = ${toString src}/.;
        }
      );
    in

    eval // {
      installer = pkgs.callPackage ${toString src}/pkgs/darwin-installer { inherit nix-darwin; };
      uninstaller = pkgs.callPackage ${toString src}/pkgs/darwin-uninstaller { inherit nix-darwin; };
    }
  '';
  darwin = import nix-darwin { inherit sources; };
  darwinSystem = darwin.system;
in
pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.morph
    pkgs.niv
    pkgs.nix
    pkgs.nix-prefetch
    pkgs.nvchecker
  ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
    (linkFarm' "nix-darwin" [
      { path = "${darwinSystem}/sw/bin/darwin-rebuild"; subPath = "bin/darwin-rebuild"; }
      { path = "${darwinSystem}/sw/bin/darwin-option"; subPath = "bin/darwin-option"; }
    ])
  ];
  NIX_PATH = pkgs.lib.concatStringsSep ":" ([
    "nixpkgs=${toString (if pkgs.stdenv.isDarwin then pkgs.pkgsDarwin.path else pkgs.path)}"
    "home-manager=${toString pkgs.home-manager.path}"
  ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
    "darwin=${toString nix-darwin}"
    "darwin-config=${toString darwin-config}"
  ]);
  NIX_SSL_CERT_FILE = "${pkgs.cacert.out}/etc/ssl/certs/ca-bundle.crt";
}
