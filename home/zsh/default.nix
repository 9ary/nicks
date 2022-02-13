{ lib, ... }:

{
  programs.zsh = lib.mkMerge [
    {
      enable = true;
    }

    # Completion
    {
      enableCompletion = true;
      completionInit = builtins.readFile ./completion.zsh;
    }

    # History options
    {
      history = {
        expireDuplicatesFirst = true;
        ignoreDups = true;
        ignoreSpace = false;
        extended = true;
        share = false;
      };
      initExtra = /*zsh*/''
        setopt HIST_FIND_NO_DUPS
        setopt HIST_REDUCE_BLANKS
      '';
    }

    # Miscellaneous options
    {
      localVariables.REPORTTIME = "5";
      initExtra = /*zsh*/''
        unsetopt BEEP
        unsetopt NOMATCH
      '';
    }

    # Key bindings
    {
      defaultKeymap = "emacs";
      initExtra = builtins.readFile ./keybindings.zsh;
    }
  ];
}

# vim: ft=nix
