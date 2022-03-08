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
  nix-prefetch-url = linkFarm' "nix-prefetch-url" [
    { path = "${pkgs.nix}/bin/nix-prefetch-url"; subPath = "bin/nix-prefetch-url"; }
  ];
in
pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.morph
    pkgs.niv
    pkgs.nix
    pkgs.nix-prefetch
    pkgs.nvchecker
  ];
  NIX_PATH = "nixpkgs=${toString pkgs.path}";
  NIX_SSL_CERT_FILE = "${pkgs.cacert.out}/etc/ssl/certs/ca-bundle.crt";
}
