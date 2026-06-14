{ pkgs, lib, ... }:

let
  serena = pkgs.writeShellScriptBin "serena" ''
    exec ${pkgs.nix}/bin/nix run github:oraios/serena -- "$@"
  '';

  # Herdr v0.6.10 (https://herdr.dev/docs/install/#install-with-nix)
  herdr =
    let
      flake = builtins.getFlake "git+https://github.com/ogulcancelik/herdr.git?rev=8b99847619235359f4aa87215feac60ac2784499";
    in
    flake.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Image textconv for git diff
  git-image-textconv = pkgs.writeShellScriptBin "git-image-textconv" ''
    # Try Kitty protocol first (best quality in WezTerm)
    ${pkgs.chafa}/bin/chafa --format=kitty --size=80x40 "$1" 2>/dev/null || \
    # Fallback to Sixel
    ${pkgs.chafa}/bin/chafa --format=sixels --size=80x40 "$1" 2>/dev/null || \
    # Fallback to symbols
    ${pkgs.chafa}/bin/chafa --format=symbols --size=80x40 "$1"
  '';

  # reminder-lint (https://github.com/CyberAgent/reminder-lint)
  reminder-lint = pkgs.stdenv.mkDerivation {
    pname = "reminder-lint";
    version = "0.2.1";
    src = pkgs.fetchurl {
      url = "https://github.com/CyberAgent/reminder-lint/releases/download/0.2.1/reminder-lint-aarch64-apple-darwin.tar.xz";
      sha256 = "0fqwnmrbw59rjs250qi90w1fzvs893sxvv6r9p9icfaz96q1s3p8";
    };
    sourceRoot = "reminder-lint-aarch64-apple-darwin";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      cp reminder-lint $out/bin/
      chmod +x $out/bin/reminder-lint
    '';
  };

  # Custom diff viewer for lazygit that supports images
  # Git worktree runner (https://github.com/coderabbitai/git-worktree-runner)
  git-gtr = pkgs.stdenv.mkDerivation {
    pname = "git-gtr";
    version = "2.4.0";
    src = pkgs.fetchFromGitHub {
      owner = "coderabbitai";
      repo = "git-worktree-runner";
      rev = "main";
      hash = "sha256-QJcpDq9guLgVjWhF2HwpMxK5ONQZtbDxFZnQrQjCRtI=";
    };
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/git-gtr $out/bin
      cp -r lib adapters templates completions $out/share/git-gtr/
      cp bin/git-gtr $out/share/git-gtr/git-gtr
      chmod +x $out/share/git-gtr/git-gtr

      # Create wrapper that sets GTR_DIR
      cat > $out/bin/gtr <<'WRAPPER'
      #!/usr/bin/env bash
      export GTR_DIR="@out@/share/git-gtr"
      exec "@out@/share/git-gtr/git-gtr" "$@"
      WRAPPER
      substituteInPlace $out/bin/gtr --replace-warn "@out@" "$out"
      chmod +x $out/bin/gtr

      # Also provide as git-gtr for `git gtr` subcommand
      cp $out/bin/gtr $out/bin/git-gtr
    '';
  };

  # terminal-notifier を WezTerm のアイコン/起動先に固定するラッパー。
  # Herdr が `terminal-notifier` を PATH で探すので、同名で前に置く。
  terminal-notifier-wezterm = pkgs.writeShellScriptBin "terminal-notifier" ''
    args=()
    skip=0
    for a in "$@"; do
      if [ "$skip" = "1" ]; then
        skip=0
        continue
      fi
      case "$a" in
        -sender|-activate)
          skip=1
          continue
          ;;
        *)
          args+=("$a")
          ;;
      esac
    done
    exec ${pkgs.terminal-notifier}/bin/terminal-notifier \
      "''${args[@]}" \
      -sender com.github.wez.wezterm \
      -activate com.github.wez.wezterm
  '';

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
    git-lfs
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
    herdr
    zoxide

    # Image viewing in terminal
    chafa  # Image-to-text converter with multiple protocol support
    viu    # Image viewer for terminal
    imagemagick  # Required by snacks.nvim image (format conversion)
    
    # Language servers for existing Neovim setup
    lua-language-server
    nil  # Nix LSP
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    gopls
    rust-analyzer
    markdown-oxide  # Markdown LSP
    pyright  # Python LSP
    
    # Development languages
    go
    rustc
    cargo
    python3
    lua5_4
    pkg-config

    # epoch-lab-server development tools
    protobuf      # proto file compilation (protoc)
    clang-tools   # clang-format for proto file formatting
    cmake         # clang-format dependency
    ninja         # clang-format dependency
    graphviz      # ER diagram generation (dot command)

    # Game development
    # godot_4 / godot-export-templates-bin は nixpkgs で Linux 限定のため macOS では除外。
    # macOS では `brew install --cask godot` で Godot 本体を導入する。
    gdtoolkit_4   # GDScript linter/formatter

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
    hyperfine  # Statistical benchmarking tool
    tree
    jq
    curl
    wget
    gnumake  # for Telescope fzf-native
    serena  # Coding agent toolkit with semantic capabilities
    git-image-textconv  # Image textconv for git diff
    lazygit-diff  # Custom diff viewer with image support
    git-gtr  # Git worktree runner
    reminder-lint  # Code reminder tool (CyberAgent)
    certbot  # Let's Encrypt certificate management
    awscli2  # AWS CLI v2
    terminal-notifier-wezterm  # WezTermのアイコン/起動先に固定したterminal-notifierラッパー
  ];
}
