{ pkgs, ... }:

{
  # Fish shell configuration (primary shell)
  programs.fish = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      ls = "lsd";
      ll = "lsd -l";
      la = "lsd -la";
      cat = "bat";
      grep = "rg";
      find = "fd";
    };
    shellInit = ''
      # Disable fish greeting
      set fish_greeting
      
      # Starship prompt
      if command -v starship >/dev/null
        starship init fish | source
      end
      
      # Zoxide
      if command -v zoxide >/dev/null
        zoxide init fish | source
      end
      
      # Custom cd function that also lists directory contents
      function cd
        builtin cd $argv[1]
        lsd
      end
      
      # Go environment
      set -x GOPATH $HOME/go
      set -x GOBIN $GOPATH/bin
      set -x PATH $PATH:$GOBIN
      
      # Add local bin to PATH
      set -x PATH $HOME/.local/bin $PATH
      
      # Mise activation
      if command -v mise >/dev/null
        mise activate fish | source
      end
    '';
    functions = {
      # Custom function for finding and editing files
      vf = "fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim";
      
      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      
      # Quick directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };
  };

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "open";
    PAGER = "less";
    MANPAGER = "nvim +Man!";
  };
}