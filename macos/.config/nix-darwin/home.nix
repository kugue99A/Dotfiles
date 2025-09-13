{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "yoheikugue";
  home.homeDirectory = "/Users/yoheikugue";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Development tools matching your current setup
    fish
    starship
    lsd
    lazygit
    zellij
    zoxide
    
    # Language servers for development
    lua-language-server
    nil  # Nix LSP
    
    # Other useful tools
    ripgrep
    fd
    bat
    fzf
  ];

  # Neovim configuration - starting simple, can be expanded
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
  # Fish shell configuration
  programs.fish = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      ls = "lsd";
    };
    shellInit = ''
      # Starship prompt
      starship init fish | source
      
      # Zoxide
      zoxide init fish | source
    '';
  };

  # Starship configuration
  programs.starship = {
    enable = true;
    # You can import your existing starship.toml here if needed
  };

  # Git configuration (if you use git)
  programs.git = {
    enable = true;
    userName = "yoheikugue";
    userEmail = "your-email@example.com";  # Update this
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}