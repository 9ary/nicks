let sources = import ../../../sources.nix; in
{ lib, config, pkgs, ... }:

{
  imports = [ ../../darwin.nix ];

  config = /*lib.mkIf (config.networking.hostName == "DUBANKS-M-9ATM")*/ {
    nixpkgs.system = "x86_64-darwin";

    nix.nixPath = [
      { darwin = toString sources.sources.nix-darwin-unstable.src; }
      { darwin-config = toString ./darwin-configuration.nix; }
      { nixpkgs = toString sources.nixpkgs.unstable.path; }
    ];

    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages = [
    ];

    # Use a custom configuration.nix location.
    # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
    # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

    # Auto upgrade nix package and the daemon service.
    services.nix-daemon.enable = true;
    nix.package = pkgs.nix;
    nix.useSandbox = "relaxed";
    nix.extraOptions = ''
      auto-optimise-store = true
      keep-derivations = true
      keep-outputs = true
      show-trace = true
    '';

    # Create /etc/bashrc that loads the nix-darwin environment.
    programs.zsh.enable = true;  # default shell on catalina
    # programs.fish.enable = true;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 4;
  };
}

