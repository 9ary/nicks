let
  inherit (builtins) elemAt fetchTarball match replaceStrings toJSON;
  escape = strings:
    replaceStrings strings (map (string: "\\${string}") strings);
  escapeJsonString = string: toJSON string;
  escapeNixString = string: escape ["$"] (escapeJsonString string);
  readJson = file: builtins.fromJSON (builtins.readFile file);
in
{ fetchFromGitHub ? null, fetchzip ? null
, useBuiltins ? false
, ... } @ args:
let
  useBuiltins' =
    if useBuiltins then spec: useBuiltins else spec: spec.builtin or false;

  fetch = abortError: name: spec:
    if !(spec ? type) then
      abortError name "should have attribute ${escapeJsonString "type"}"
    else if fetchers ? ${spec.type} then fetchers.${spec.type} name spec
    else abortError name "has unknown type ${escapeJsonString spec.type}";

  fetchers.github = name:
    { owner, repo, rev, sha256, fetchSubmodules ? false, ... } @ spec:
    if useBuiltins' spec then assert !fetchSubmodules; fetchTarball {
      name = "source";
      url = "https://api.github.com/repos/${owner}/${repo}/tarball/${rev}";
      inherit sha256;
    } else assert fetchFromGitHub != null; fetchFromGitHub {
      inherit owner repo rev sha256 fetchSubmodules;
    };

  fetchers.tarball = name: { url, sha256, ... } @ spec:
    let
      matchUrl = regex: match regex url;

      spec_github =
        if spec_github_noApi != null then spec_github_noApi
        else spec_github_api;
      spec_github_noApi = let urlMatches = matchUrl
        ''https://github\.com/([^/]+)/([^/]+)/archive/([^/]+)\.tar\.gz'';
      in if urlMatches == null then null else spec // {
        owner = elemAt urlMatches 0;
        repo = elemAt urlMatches 1;
        rev = elemAt urlMatches 2;
      };
      spec_github_api = let urlMatches = matchUrl
        ''https://github\.com/([^/]+)/([^/]+)/archive/([^/]+)\.tar\.gz'';
      in if urlMatches == null then null else spec // {
        owner = elemAt urlMatches 0;
        repo = elemAt urlMatches 1;
        rev = elemAt urlMatches 2;
      };
    in
    if spec_github != null then fetchers.github name spec_github
    else if useBuiltins' spec then fetchTarball {
      name = "source";
      inherit url sha256;
    } else assert fetchzip != null; fetchzip {
      inherit url sha256;
    };
in
{ sourcesFile ? null, unfetchedSources ? null }:
let
  unfetchedSources' = if unfetchedSources == null then readJson sourcesFile
    else unfetchedSources;
  sourcesFile' = if sourcesFile == null then null else toString sourcesFile;
  abortError = if sourcesFile' != null then name: msg:
    abort "ERROR: niv spec ${escapeJsonString name} in ${sourcesFile'} ${msg}"
  else name: msg: abort "ERROR: niv spec ${escapeJsonString name} ${msg}";
  fetch' = fetch abortError;
in
builtins.mapAttrs (name: spec:
  if spec ? outPath then
    abortError name "should not have attribute ${escapeJsonString "outPath"}"
  else {
    pname = spec.pname or name;
    version = spec.version or spec.rev;
    src = fetch' name spec;
  }
) unfetchedSources'
