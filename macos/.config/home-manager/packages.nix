{ pkgs, ... }:

{
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
    markdown-oxide  # Markdown LSP
    deno  # Deno LSP (denols)
    pyright  # Python LSP
    
    # Development languages
    go
    rustc
    cargo
    python3
    
    # Other useful tools
    htop
    tree
    jq
    curl
    wget
  ];
}
