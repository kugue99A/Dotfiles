{ pkgs, ... }:

let
  serena = pkgs.writeShellScriptBin "serena" ''
    exec ${pkgs.nix}/bin/nix run github:oraios/serena -- "$@"
  '';
in
{
  home.packages = with pkgs; [
    # Editor (without Home Manager configuration)
    neovim
    
    # Development tools
    git
    gh  # GitHub CLI
    starship
    
    # Essential CLI tools
    ripgrep
    fd
    bat
    fzf
    lsd
    lazygit
    delta  # git diff pager
    ghq    # repository management
    zellij
    zoxide
    
    # Language servers for existing Neovim setup
    lua-language-server
    nil  # Nix LSP
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    gopls
    rust-analyzer
    markdown-oxide  # Markdown LSP
    deno  # Deno LSP (denols)
    pyright  # Python LSP
    
    # Development languages
    go
    rustc
    cargo
    python3
    lua5_4
    pkg-config
    
    # Window manager
    aerospace  # i3-like tiling window manager for macOS

    # Other useful tools
    htop
    tree
    jq
    curl
    wget
    gnumake  # for Telescope fzf-native
    serena  # Coding agent toolkit with semantic capabilities
  ];
}
