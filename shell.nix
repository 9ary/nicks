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

  darwin = import sources.nix-darwin { inherit sources; };
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
    "darwin=${toString sources.nix-darwin}"
    "darwin-config=${toString sources.darwin-config}"
  ]);
  NIX_SSL_CERT_FILE = "${pkgs.cacert.out}/etc/ssl/certs/ca-bundle.crt";
}
