{ config, pkgs, ... }:

{
  imports = [ <home-manager/nixos> ];
  config = {
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
    };

    users.groups.novenary = {
      gid = 1000;
    };
    users.users.novenary = {
      isNormalUser = true;
      uid = 1000;
      group = "novenary";
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        # Akatsuki
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjP3oqGRcXPoCJd08yqfhrPf7RGRYbZT0dGzdu9NgiACIOR+3vEREl2lp41wDp9HF3aRqwAXzLZ8AYk8zCCeSBwAivyA7Y+91S/fo7koFnU4ZYzqgWfeIN2m6zXl/E9ZI3Cy5A3TUxy4OQoAviqsJiyUa6YIgzQ0WJ2NQKNkDMfGxvD52TwuKtU+XlEJ4vBekhMEjbhptVxJcMAoSaHYC0r4D0cRFSxeVOX4HBIiociAbC2bpxRhe/pT0GvzBbmg+OPGHegtyIMS5ndmqn3BBc2+NOnQN0qZGCs0gG+XT570icRJMWIGj+yBVzde7htyat+ttect6Am/FXaFgPrQIT"
        # Hitagi
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC7Imp6NwHMa/zD+y0C11h4PbPqFobL7fDiTKwG7GDe5BSVhWLKxNRd+A5CioC2B4jWitYoJyLnZyaMElE11ZEPMx1YNH8NUABJ4+xzP4AxASl2WISbqAEfUHAfwnK1R3Cf83JTpOrAFYIFaYViO3+TIoN5hMJmKaWu6K6JcSw1mMcPkmctkrR/fqFkcGB3Uj+ECPvg6+u52PBRPrnr7JLgxPuPHI5J10CB+5AvteFZDHL/nAnEU8pa6iQO7Q17TKxLd+ngmqajWlZRBYoXniqvZxp9tS5n2AG3htLZgbHVX141R885ze7B6EDs/IqTrCHLUcxsnfFO7UzaKdD++GX"
      ];
    };
    home-manager.users.novenary = import ../../home;
  };
}
