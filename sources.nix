let
  sourcesBoot = import _sources/generated.nix;
  fetchersBoot = fetchersFinal: {
    fetchTarball = builtins.fetchTarball;
    fetchFromGitHub = (
      { owner, repo, rev, sha256, fetchSubmodules ? false }:
      assert fetchSubmodules == false;
      fetchersFinal.fetchTarball {
        name = "source";
        url = "https://api.github.com/repos/${owner}/${repo}/tarball/${rev}";
        inherit sha256;
      }
    );
  };
  fetchedSourcesBoot = let
    functionArgs = f:
      if f ? __functor
      then f.__functionArgs or (functionArgs (f.__functor f))
      else builtins.functionArgs f;
    isFunction = f: builtins.isFunction f ||
      (f ? __functor && isFunction (f.__functor f));
    fix = f: let final = f final; in final;
    callPackageWith= autoArgs: fn: args:
      let
        f = if isFunction fn then fn else import fn;
        fArgs = functionArgs f;
        throwMissing = name: hasDefault: throw "callPackageWith: missing attr ${name}";
        fallback = builtins.mapAttrs throwMissing fArgs;
        auto = builtins.intersectAttrs fArgs autoArgs;
      in f (fallback // auto // args);
  in callPackageWith (fix fetchersBoot) sourcesBoot { };
  libBoot = import "${fetchedSourcesBoot.nixpkgs-lib.src}/lib";
in
libBoot.makeScope libBoot.callPackageWith (final: {
  sources = sourcesBoot;
  fetchedSources = final.fetchers.callPackage final.sources { };
  lib = libBoot;
  fetchers = final.lib.makeScope final.newScope (final.lib.extends (fetchersFinal: fetchersPrev: {
    fetchgit = final.nixpkgs.fetchgit;
    fetchurl = final.nixpkgs.fetchurl;
  }) fetchersBoot);
  nixpkgsConfig = {
  };
  nixpkgsOverlays = [
    (pkgsFinal: pkgsPrev: let
      libFinal = pkgsFinal.lib;
      fetchedSources = pkgsFinal.callPackage final.sources { };
    in {
      haskell = let
        haskellLibFinal = pkgsFinal.haskell.lib;
      in pkgsPrev.haskell // {
        packageOverrides = let
          packageOverridesPrev = pkgsPrev.haskell.packageOverrides or (haskellFinal: haskellPrev: { });
        in libFinal.composeExtensions packageOverridesPrev (haskellFinal: haskellPrev: {
          nvfetcher = haskellLibFinal.generateOptparseApplicativeCompletion "nvfetcher" (haskellLibFinal.overrideCabal
            (haskellFinal.callPackage "${fetchedSources.nvfetcher.src}/nix" { })
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
  callNixpkgs = nixpkgs: nixpkgs {
    config = final.nixpkgsConfig;
    overlays = final.nixpkgsOverlays;
  };
  nixos-unstable = final.callNixpkgs (import final.fetchedSources.nixos-unstable.src);
  nixos-21_11 = final.callNixpkgs (import final.fetchedSources.nixos-21_11.src);
  nixos-stable = final.nixos-21_11;
  nixpkgs = final.nixos-stable;
})
