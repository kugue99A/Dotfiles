{ pkgs, ... }:

let
  serena = pkgs.writeShellScriptBin "serena" ''
    exec ${pkgs.nix}/bin/nix run github:oraios/serena -- "$@"
  '';

  # Image textconv for git diff
  git-image-textconv = pkgs.writeShellScriptBin "git-image-textconv" ''
    # Try Kitty protocol first (best quality in WezTerm)
    ${pkgs.chafa}/bin/chafa --format=kitty --size=80x40 "$1" 2>/dev/null || \
    # Fallback to Sixel
    ${pkgs.chafa}/bin/chafa --format=sixels --size=80x40 "$1" 2>/dev/null || \
    # Fallback to symbols
    ${pkgs.chafa}/bin/chafa --format=symbols --size=80x40 "$1"
  '';

  # Custom diff viewer for lazygit that supports images
  lazygit-diff = pkgs.writeShellScriptBin "lazygit-diff" ''
    # Check if we're diffing an image file
    file="$1"

    # Image extensions to detect
    if [[ "$file" =~ \.(png|jpg|jpeg|gif|bmp|webp|svg|ico)$ ]]; then
      # For image files, show both old and new versions side by side
      echo "=== Image Diff: $file ==="
      echo ""

      # Show the file with chafa using Kitty protocol for high-quality display
      if [ -f "$file" ]; then
        echo "Current version:"
        # Try Kitty protocol first (best quality in WezTerm)
        ${pkgs.chafa}/bin/chafa --format=kitty --size=80x40 "$file" 2>/dev/null || \
        # Fallback to Sixel protocol
        ${pkgs.chafa}/bin/chafa --format=sixels --size=80x40 "$file" 2>/dev/null || \
        # Fallback to symbols if protocols not supported
        ${pkgs.chafa}/bin/chafa --format=symbols --size=80x40 "$file" 2>/dev/null || \
        # Last resort: viu
        ${pkgs.viu}/bin/viu -w 80 "$file" 2>/dev/null || \
        echo "[Unable to display image]"
      fi
    else
      # For text files, use delta
      exec ${pkgs.delta}/bin/delta --dark --paging=never --side-by-side --line-numbers "$@"
    fi
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

    # Image viewing in terminal
    chafa  # Image-to-text converter with multiple protocol support
    viu    # Image viewer for terminal
    
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

    # Container runtime
    colima   # Container runtimes on macOS with minimal setup
    docker   # Docker CLI (works with Colima backend)
    
    # Window manager
    aerospace  # i3-like tiling window manager for macOS

    # Nerd Fonts
    nerd-fonts.sauce-code-pro
    nerd-fonts.hack
    sketchybar-app-font  # SketchyBar用アプリアイコンフォント（リガチャベース）

    # Other useful tools
    htop
    tree
    jq
    curl
    wget
    gnumake  # for Telescope fzf-native
    serena  # Coding agent toolkit with semantic capabilities
    git-image-textconv  # Image textconv for git diff
    lazygit-diff  # Custom diff viewer with image support
  ];
}
