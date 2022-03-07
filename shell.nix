let sources = import ./sources.nix; in
{ pkgs ? sources.nixpkgs
}:

pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.morph
    pkgs.nix-prefetch
    pkgs.nvchecker
  ];
  NIX_PATH = "nixpkgs=${toString pkgs.path}";
  NIX_SSL_CERT_FILE = "${pkgs.cacert.out}/etc/ssl/certs/ca-bundle.crt";
}
