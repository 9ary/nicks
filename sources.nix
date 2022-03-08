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
  nixpkgsArgs.default.aliases = {
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
      haskell = let
        haskellLibFinal = pkgsFinal.haskell.lib;
      in pkgsPrev.haskell // {
        packageOverrides = let
          packageOverridesPrev = pkgsPrev.haskell.packageOverrides or (haskellFinal: haskellPrev: { });
        in libFinal.composeExtensions packageOverridesPrev (haskellFinal: haskellPrev: {
          nvfetcher = haskellLibFinal.generateOptparseApplicativeCompletion "nvfetcher" (haskellLibFinal.overrideCabal
            (haskellFinal.callPackage "${pkgsFinal.sources.nvfetcher.src}/nix" { })
            (drvPrev: {
              # test needs network
              doCheck = false;
              buildTools = drvPrev.buildTools or [ ] ++ [ pkgsFinal.makeWrapper ];
              postInstall = drvPrev.postInstall or "" + ''
                wrapProgram "$out"/bin/nvfetcher \
                  --prefix PATH ':' ${libFinal.escapeShellArg (libFinal.makeBinPath [
                    pkgsFinal.nix-prefetch
                    pkgsFinal.nvchecker
                  ])}
              '';
            })
          );
        });
      };
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
  nixpkgsArgs.nixos-unstable.overlays = [
    (pkgsFinal: pkgsPrev: {
      sources = pkgsPrev.sources // {
        home-manager = pkgsFinal.sources.home-manager-unstable;
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
    default = final.nixpkgsArgs.default.aliases.pkgsDefault;
    stable = final.nixpkgsArgs.default.aliases.pkgsStable;
    unstable = final.nixpkgsArgs.default.aliases.pkgsUnstable;
  };
  sources = let sourcesPrev = prev.sources; in sourcesPrev // {
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
