{ ... }:

{
  imports = import ./module-list.nix;

  config = {
    home.stateVersion = "21.11";
  };
}
