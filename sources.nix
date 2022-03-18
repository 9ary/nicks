let makeSources = final: {
  fetchSources = final.callPackage _sources/fetch-sources.nix final.fetchers;
  fetchers = { useBuiltins = true; };
  lib = import "${final.sources.nixpkgs-lib.src}/lib";
  sources = final.fetchSources { inherit (final) sourcesFile unfetchedSources; };
  sourcesFile = ./_sources/nix/sources.json;
  unfetchedSources = builtins.fromJSON (builtins.readFile final.sourcesFile);
}; in let boot = makeSources boot // {
    fetchSources = import _sources/fetch-sources.nix boot.fetchers;
}; in (let
  inherit (boot.lib) callPackageWith extends makeScope;
  extendingSources = g: makeScope callPackageWith (extends g makeSources);
in extendingSources) (final: prev: {
  darwin-config = ./modules/hosts/DUBANKS-M-9ATM/darwin-configuration.nix;
  nix-darwin = let
    src = final.nixpkgs.darwin.sources.nix-darwin.src;
  in final.nixpkgs.darwin.writeText "nix-darwin-default.nix" ''
    { sources ? import ${toString ./sources.nix}
    , nixpkgs ? toString sources.nixpkgs.darwin.path
    , configuration ? ${toString final.darwin-config}
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

      writeProgram = name: env: src: pkgs.substituteAll ({
        inherit name src;
        dir = "bin";
        isExecutable = true;
      } // env);

      profile = "/nix/var/nix/profiles/system";
    in

    eval // {
      darwin-option = writeProgram "darwin-option" {
        inherit profile;
        inherit (pkgs.stdenv) shell;
      } ${toString src}/pkgs/nix-tools/darwin-option.sh;
      darwin-rebuild = writeProgram "darwin-rebuild" {
        inherit profile;
        inherit (pkgs.stdenv) shell;
        path = lib.makeBinPath [ pkgs.coreutils pkgs.jq ];
      } ${toString src}/pkgs/nix-tools/darwin-rebuild.sh;
      installer = pkgs.callPackage ${toString src}/pkgs/darwin-installer { inherit nix-darwin; };
      uninstaller = pkgs.callPackage ${toString src}/pkgs/darwin-uninstaller { inherit nix-darwin; };
    }
  '';
  nixpkgsArgs.default.aliases = {
    pkgsDarwin = final.nixpkgs.nixos-darwin;
    pkgsDefault = final.nixpkgsArgs.default.aliases.pkgsStable;
    pkgsStable = final.nixpkgs.nixos-21_11;
    pkgsUnstable = final.nixpkgs.nixos-unstable;
    sources = final.sources;
    unfetchedSources = final.unfetchedSources;
  };
  nixpkgsArgs.default.config = {
    allowUnfree = true;
  };
  nixpkgsArgs.default.overlays = [
    (pkgsFinal: pkgsPrev: let
      libFinal = pkgsFinal.lib;
    in {
      home-manager = pkgsFinal.callPackage pkgsFinal.sources.home-manager.src {
        pkgs = pkgsFinal;
      };
      local = {
        gitprompt-rs = pkgsFinal.callPackage ./pkgs/gitprompt-rs {};
        python-pyalsaaudio = pkgsFinal.callPackage ./pkgs/python/pyalsaaudio.nix {};
      };
      morph = import pkgsFinal.sources.morph.src {
        pkgs = pkgsFinal;
        version = pkgsFinal.sources.morph.version;
      };
      nix-prefetch = pkgsPrev.nix-prefetch.overrideAttrs (attrsPrev: {
        patches = attrsPrev.patches or [ ] ++ [
          # https://github.com/msteen/nix-prefetch/pull/34/
          (pkgsFinal.fetchpatch {
            url = "https://github.com/msteen/nix-prefetch/commit/9da16d679c67dd80d9c3a2719790045151c3de2f.patch";
            sha256 = "0z76q24sf9mdc9h6b94ga96xgq3a9dl0adzcmi2fws0v7r7fnqja";
          })
        ];
      });
    })
  ];
  nixpkgsArgs.nixos-21_11.overlays = [
    (pkgsFinal: pkgsPrev: {
      sources = pkgsPrev.sources // {
        home-manager = pkgsFinal.sources.home-manager-21_11;
      };
    })
  ] ++ final.nixpkgsArgs.default.overlays or [ ];
  nixpkgsArgs.nixos-darwin = let
    nixpkgsArgsPrev = final.nixpkgsArgs.nixos-unstable;
  in nixpkgsArgsPrev // {
    system = "x86_64-darwin";
  };
  nixpkgsArgs.nixos-unstable.overlays = [
    (pkgsFinal: pkgsPrev: {
      sources = pkgsPrev.sources // {
        home-manager = pkgsFinal.sources.home-manager-unstable;
        nix-darwin = pkgsFinal.sources.nix-darwin-unstable;
      };
    })
  ] ++ final.nixpkgsArgs.default.overlays or [ ];
  nixpkgs = let
    nixpkgsArgsDefault = final.nixpkgsArgs.default;
  in builtins.mapAttrs (name: nixpkgsArgs:
    import final.sources.${name}.src (builtins.removeAttrs (let
      nixpkgsArgs' = nixpkgsArgsDefault // nixpkgsArgs;
    in if nixpkgsArgs' ? aliases then nixpkgsArgs' // {
      overlays = [
        (pkgsFinal: pkgsPrev: nixpkgsArgs'.aliases)
      ] ++ nixpkgsArgs'.overlays or [ ];
    } else nixpkgsArgs') [ "aliases" ])
  ) (builtins.removeAttrs final.nixpkgsArgs [ "default" ]) // {
    darwin = final.nixpkgsArgs.default.aliases.pkgsDarwin;
    default = final.nixpkgsArgs.default.aliases.pkgsDefault;
    stable = final.nixpkgsArgs.default.aliases.pkgsStable;
    unstable = final.nixpkgsArgs.default.aliases.pkgsUnstable;
  };
  sources = let
    sourcesFinal = final.sources;
    sourcesPrev = prev.sources;
  in sourcesPrev // {
    nixos-darwin = sourcesFinal.nixos-unstable // { name = "nixos-darwin"; };
    morph = let sourcePrev = sourcesPrev.morph; in sourcePrev // {
      src = final.nixpkgs.default.applyPatches {
        name = "source";
        src = sourcePrev.src;
        patches = [
          ./morph-0001-without-with-expr.patch
          ./morph-0002-eval-machines-support-specialArgs.patch
        ];
      };
    };
  };
})
