{ lib, pkgs, ... }:

{
  imports = [
    ./dircolors.nix
  ];

  config = {
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
          ignorePatterns = [
            "fg *"
          ];
        };
        initExtra = /*zsh*/''
          setopt HIST_FIND_NO_DUPS
          setopt HIST_REDUCE_BLANKS
        '';
      }

      # Miscellaneous options
      {
        initExtra = /*zsh*/''
          REPORTTIME=5
          unsetopt BEEP
          unsetopt NOMATCH

          # Issue a BELL when a command is done to draw attention to the terminal
          function precmd() {
              echo -ne '\a'
          }
        '';
      }

      # Key bindings
      {
        defaultKeymap = "emacs";
        initExtra = builtins.readFile ./keybindings.zsh;
      }

      # Prompt
      {
        initExtra = builtins.readFile ./prompt.zsh;
      }

      # Plugins
      {
        enableAutosuggestions = true;
        enableSyntaxHighlighting = true;
        plugins = [
          {
            name = "zsh-history-substring-search";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-history-substring-search";
              rev = "4abed97b6e67eb5590b39bcd59080aa23192f25d";
              sha256 = "0s8xdddb6zppc5lj28w44nl4n45wg9ic8x3b5pm1139cv038yj7j";
            };
          }
        ];
        initExtra = /*zsh*/''
          ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=7'

          ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

          HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=black,bold'
          HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=black,bold'
        '';
      }

      # Aliases and functions
      {
        shellAliases = {
          # TODO move aliases to relevant program-specific modules
          sudo = "sudo ";
          ls = "ls --color=auto --dereference-command-line-symlink-to-dir -Fh";
          lsa = "ls --color=auto --dereference-command-line-symlink-to-dir -FAh";
          ll = "ls --color=auto --dereference-command-line-symlink-to-dir -Fhl";
          lla = "ls --color=auto --dereference-command-line-symlink-to-dir -FAhl";
          cp = "cp -r";
          rsync = "rsync -rPh --info=PROGRESS2";
          v = "nvim";
          sv = "sudo nvim";
          rg = "rg -S";
          pgrep = "pgrep -l";
          verynice = "schedtool -B -n 15 -e ionice -c3";
        };
      }
    ];
  };
}

# vim: ft=nix
