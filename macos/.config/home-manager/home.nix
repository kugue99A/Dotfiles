{ config, pkgs, ... }:

{
  home.username = "yoheikugue";
  home.homeDirectory = "/Users/yoheikugue";
  home.stateVersion = "25.05";

  # Packages - Neovim and tools without configuration management
  home.packages = with pkgs; [
    # Editor (without Home Manager configuration)
    neovim
    
    # Development tools
    git
    starship
    
    # Essential CLI tools
    ripgrep
    fd
    bat
    fzf
    lsd
    lazygit
    zellij
    zoxide
    
    # Language servers for existing Neovim setup
    lua-language-server
    nil  # Nix LSP
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    gopls
    rust-analyzer
    
    # Development languages
    go
    rustc
    cargo
    nodejs
    python3
    
    # Other useful tools
    htop
    tree
    jq
    curl
    wget
  ];

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

  # Starship configuration
  programs.starship = {
    enable = true;
    settings = {
      format = "$all$character";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
        vimcmd_symbol = "[➜](bold green)";
      };
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      git_branch = {
        symbol = " ";
      };
      nodejs = {
        symbol = " ";
      };
      python = {
        symbol = " ";
      };
      rust = {
        symbol = " ";
      };
      golang = {
        symbol = " ";
      };
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "yoheikugue";
    userEmail = "your-email@example.com";  # Update this with your email
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = false;
    };
  };

  # Zoxide (smart cd command)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Bat (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
      pager = "less -FR";
    };
  };

  # FZF (fuzzy finder)
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
  };

  # Lazygit
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          lightTheme = false;
          activeBorderColor = ["#d79921" "bold"];
          inactiveBorderColor = ["#a89984"];
          selectedLineBgColor = ["#3c3836"];
        };
      };
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

  programs.home-manager.enable = true;
}