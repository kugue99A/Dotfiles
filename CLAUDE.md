# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

日本語で回答

## neovimの問題はこちらを読む
* https://neovim.io/doc/user/lsp.html

## Repository Overview

This is a personal dotfiles repository for macOS development environment with a terraform-like management interface. The repository provides comprehensive configuration for Fish shell, Neovim, Zellij terminal multiplexer, AeroSpace window manager, Sketchybar status bar, and various development tools, all unified under a Gruvbox Dark theme.

## Core Commands

### Dotfiles Management (Terraform-like Interface)
```bash
# Check current status of configurations
./dotfiles status

# Preview what changes would be made (dry-run)
./dotfiles plan

# Apply configuration changes (creates symlinks and backups)
./dotfiles apply

# Remove managed symlinks
./dotfiles destroy
```

### Home Manager (Nix) Integration
```bash
# Apply Nix Home Manager configuration
home-manager switch

# Update Nix channels and apply
nix-channel --update && home-manager switch

# View Home Manager generations (for rollback)
home-manager generations
```

### Development Environment Commands
```bash
# Mise - Runtime version management
mise install                # Install tools from config.toml
mise upgrade                # Upgrade all tools to latest versions
mise use <tool>@<version>   # Add tool to config.toml
mise list                   # Show installed tools
mise current                # Show active tool versions

# Neovim plugin management
nvim +:Lazy sync            # Sync plugins (install/update/clean)
nvim +:Lazy update          # Update plugins

# Fish shell reload
source ~/.config/fish/config.fish

# AeroSpace window manager
aerospace reload-config     # Reload configuration
aerospace list-workspaces   # List all workspaces
aerospace list-windows      # List all windows

# Sketchybar status bar
sketchybar --reload         # Reload configuration
sketchybar --update         # Force update all items
```

## Architecture and Management Strategy

### Dual Configuration System
The repository implements a hybrid approach:

1. **Manual Configuration**: Traditional dotfiles managed via the `./dotfiles` script with terraform-like operations
2. **Nix Home Manager**: Declarative package and configuration management for system-level tools

### Key Integration Points

- **Theme Consistency**: All applications use Gruvbox Dark theme (Neovim, Zellij, Starship, terminal)
- **Shell Integration**: Fish shell as the central hub with custom functions, aliases, and environment setup
- **LSP Management**: Neovim uses modern `vim.lsp.config` and `vim.lsp.enable` API (NOT Mason) with individual server configuration files in `lua/lsp/` directory
- **Plugin Management**: Lazy.nvim for Neovim
- **Runtime Management**: Mise for language version management (Node.js, Python, Go, Lua, Rust, etc.)
- **Window Management**: AeroSpace (i3-like tiling) integrated with Sketchybar for workspace display

### Directory Structure Logic
```
macos/.config/          # Source configurations
├── fish/               # Fish shell with custom functions (managed by Nix)
├── nvim/               # Modular Neovim setup with lazy.nvim
├── zellij/             # Terminal multiplexer with tmux-like bindings
├── home-manager/       # Nix configuration split by functionality
│   ├── home.nix        # Main Home Manager entry point
│   ├── packages.nix    # System packages and LSP servers
│   ├── shell.nix       # Fish shell configuration and functions
│   ├── git.nix         # Git configuration
│   ├── terminal.nix    # Terminal emulator settings
│   ├── aerospace.nix   # Window manager configuration
│   └── sketchybar.nix  # Status bar configuration
├── mise/               # Runtime version management
└── raycast/            # Raycast extensions (built, not source)
```

### Safety and Backup System
The `./dotfiles` script implements:
- Automatic backup creation before any changes (`~/.config.backup/TIMESTAMP/`)
- Nix-managed file detection and skipping to prevent conflicts
- State tracking via `.dotfiles_state` file
- Non-destructive operations by default

### Nix Integration Benefits
- Declarative package management for development tools
- Consistent environment across machines
- Atomic updates and easy rollbacks
- Separation of system packages from user configurations

## Development Workflow Patterns

### Adding New Configurations
1. Place configuration files in `macos/.config/[app]/`
2. Test with `./dotfiles plan` to preview changes
3. Apply with `./dotfiles apply`
4. For system packages, add to appropriate Nix file in `home-manager/`

### LSP Server Setup (Neovim)
**CRITICAL**: This setup uses modern Neovim 0.10+ `vim.lsp.config` and `vim.lsp.enable` API, NOT Mason or nvim-lspconfig.

1. **Install LSP server** via Nix: Add to `macos/.config/home-manager/packages.nix`
   ```nix
   nodePackages.typescript-language-server  # Example
   gopls
   rust-analyzer
   lua-language-server
   ```
2. **Configure in Neovim**: Edit `macos/.config/nvim/lua/core/lsp.lua`
   - Define server config using `vim.lsp.config.<server_name> = { ... }`
   - Add server name to `servers_to_enable` table
   - Call `vim.lsp.enable(server)` to activate
3. **Optional custom config**: Create `lua/lsp/[server_name].lua` for server-specific overrides
   - These are loaded via `load_server_config()` function
   - Merged with default config using `vim.tbl_deep_extend()`
4. **Apply changes**:
   - Run `home-manager switch` to install LSP server
   - Restart Neovim or run `:LspRestart`
   - Check with `:LspInfo` (custom command)

**Available LSP servers** (see `lua/core/lsp.lua`):
- `lua_ls` - Lua Language Server
- `ts_ls` - TypeScript/JavaScript
- `html` - HTML (with Templ support)
- `cssls` - CSS/SCSS/Less
- `gopls` - Go
- `rust_analyzer` - Rust
- `pyright` - Python
- `denols` - Deno (only when deno.json exists)
- `tsp_server` - TypeSpec

### Theme and Visual Consistency
- Use Gruvbox Dark color scheme across all applications
- Consistent terminal settings (Font: monospace, transparency settings)
- Unified prompt styling via Starship configuration

### Environment Variables and Paths
- Fish shell manages PATH modifications and environment setup (via Nix `shell.nix`)
- Mise handles runtime version management (Node.js, Python, Go, Lua, Rust, etc.)
  - Configuration: `macos/.config/mise/config.toml`
  - Installed tools: `~/.local/share/mise/installs/`
  - Mise is activated in Fish shell init
- Home Manager provides system-level package installation (via `packages.nix`)

### State Management
- Manual configurations: Tracked via `.dotfiles_state`
- Nix configurations: Managed via Home Manager generations
- Plugin states: Neovim `lazy-lock.json`
- Mise tools: Tracked in `~/.local/share/mise/installs/`

### Raycast Extensions
The repository includes compiled (built) Raycast extensions, NOT source code:
- **Color Picker** (`40ebc708-964f-473b-8d19-d4e9cbd27ae9/`) - Color picker and conversion tool
- **Arc Browser** (`606e26d8-b3c5-4760-8001-dccce1b872c4/`) - Arc browser integration
- **System Monitor** (`c0c9423a-7014-481e-8bb9-44c4c6df53be/`) - Process management

**Note**: These are compiled JavaScript files with source maps, not TypeScript source. Do NOT attempt to modify these files directly. Rebuild from source if modifications are needed.

## Key Integration Features

### Neovim Modern Architecture
- Uses Lua-based configuration with modular structure
- Core modules loaded from `lua/core/`: options, keymaps, lsp, highlights
- Plugin management via lazy.nvim in `lua/plugins/`
- LSP servers configured individually in `lua/lsp/` directory
- Leader key: Space, Local leader: Backslash

### Zellij Terminal Multiplexer
- Prefix key: `Ctrl+q` (tmux-style workflow)
- Vim-style pane navigation (hjkl keys)
- Custom Gruvbox Dark theme integration
- Session management with `.zellij` directory

### AeroSpace Window Manager
- **Type**: i3-like tiling window manager for macOS
- **Configuration**: Generated by Nix from `macos/.config/home-manager/aerospace.nix`
- **Key bindings** (all start with `alt-shift`):
  - `alt-shift-hjkl` - Focus window (vim-style)
  - `ctrl-alt-shift-hjkl` - Move window
  - `alt-shift-1~9` - Switch to workspace
  - `ctrl-alt-shift-1~9` - Move window to workspace
  - `alt-shift-f` - Toggle fullscreen
  - `alt-shift-slash` - Tiles layout
  - `ctrl-alt-shift-f` - Toggle floating
  - `ctrl-alt-shift-semicolon` - Enter service mode
- **Integration**: Triggers Sketchybar updates on workspace changes
- **Auto-float apps**: System Preferences, Calculator, Activity Monitor, App Store

### Sketchybar Status Bar
- **Type**: Custom status bar for macOS (top of screen)
- **Configuration**: Managed by Nix in `macos/.config/home-manager/sketchybar.nix`
- **Features**:
  - Workspace indicator (synced with AeroSpace)
  - System information display
  - Custom icon font for app icons
- **Integration**: Listens to AeroSpace workspace change events via `aerospace_workspace_change` trigger

### Fish Shell Custom Functions
**IMPORTANT**: Fish functions are managed by Nix Home Manager, NOT by the `./dotfiles` script.
- Defined in: `macos/.config/home-manager/shell.nix`
- Deployed to: `~/.config/fish/functions/` (as symlinks to Nix store)
- Key functions:
  - `.....fish`, `....fish`, `...fish` - Directory navigation shortcuts (cd ../..)
  - `ga.fish`, `gc.fish`, `gd.fish`, `gl.fish`, `gp.fish`, `gs.fish` - Git shortcuts
  - `vf.fish` - Fuzzy finder integration (fzf + fd)

To modify Fish functions, edit `shell.nix` and run `home-manager switch`.

## Troubleshooting Common Issues

### Neovim LSP Problems
- Check `:LspInfo` for server status (custom command, not from nvim-lspconfig)
- Verify server installation in Nix `packages.nix` (LSP servers installed via Nix, NOT Mason)
- Review server config in `lua/lsp/[server].lua` (individual server configs)
- Check core LSP setup in `lua/core/lsp.lua`
- Restart LSP: `:LspRestart`
- **Note**: This setup uses `vim.lsp.config` + `vim.lsp.enable`, NOT Mason or nvim-lspconfig

### Mise Runtime Management Issues
- Check installed tools: `mise list`
- Check current versions: `mise current`
- Reinstall a tool: `mise uninstall <tool>@<version> && mise install`
- Clear download cache: `rm -rf ~/.local/share/mise/downloads/<tool>/<version>`
- Upgrade issues: If `mise upgrade` fails, check specific tool compatibility
  - Example: Lua 5.5.0 has LuaRocks compatibility issues, use `lua = "5.4"` instead of `"latest"`
- Configuration: Edit `~/.config/mise/config.toml` and run `mise install`
- Mise activation: Ensure `mise activate fish | source` is in Fish shell init (managed by Nix)

### Dotfiles Conflicts
- Check for Nix-managed files: Files managed by Home Manager are automatically skipped by `./dotfiles` script
- Review backup location: `~/.config.backup/TIMESTAMP/`
- State conflicts: Check `.dotfiles_state` for tracking issues
- Fish functions: Do NOT use `./dotfiles` to manage Fish functions, use `home-manager switch` instead

### Home Manager Issues
- Channel updates: `nix-channel --update && home-manager switch`
- Generation rollback: `home-manager generations` then activate specific generation
- Detailed errors: `home-manager switch --show-trace`
- Fish shell changes: After editing `shell.nix`, run `home-manager switch` and restart shell

### AeroSpace Window Manager Issues
- Reload config: `aerospace reload-config` or `ctrl-alt-shift-semicolon` then `esc` (service mode)
- Check workspace: `aerospace list-workspaces --focused`
- Check windows: `aerospace list-windows --workspace <number>`
- Restart AeroSpace: Quit from menu bar and relaunch
- Configuration: Managed by Nix at `aerospace.nix`, do NOT edit `~/.config/aerospace/aerospace.toml` directly

### Sketchybar Status Bar Issues
- Reload config: `sketchybar --reload`
- Force update: `sketchybar --update`
- Check if running: `pgrep -f sketchybar`
- Restart: `killall sketchybar && sketchybar`
- Configuration: Managed by Nix at `sketchybar.nix`

## Claude Code スキル

このリポジトリには、Claude Codeで使用できるスキル（スラッシュコマンド）が用意されています。

### 利用可能なスキル

| スキル | コマンド | 説明 |
|--------|---------|------|
| Nix Home-Manager | `/nix-home-manager` | Nix/Home-Manager設定の詳細ガイド、パターン、トラブルシューティング |
| AeroSpace + SketchyBar | `/sketchybar-aerospace` | ウィンドウマネージャとステータスバーの設定ガイド |

### 使い方

```
/nix-home-manager
```

これにより、Claude CodeがNix/Home-Manager設定に関する詳細なコンテキストを取得し、より正確な回答やコード編集が可能になります。

### スキルが役立つ場面

- **Nix Home-Manager**: 新しいパッケージ追加、モジュール作成、設定変更、トラブルシューティング
- **SketchyBar/AeroSpace**: ウィジェット追加、キーバインド変更、テーマカスタマイズ

## サブエージェント活用ガイドライン

Claude Codeは複雑なタスクに対して専用のサブエージェントを使用できます。このリポジトリでの推奨使用法：

### Nix/Home-Manager タスク

| タスク種別 | 推奨エージェント | 用途 |
|-----------|----------------|------|
| 設定調査 | `Explore` | Home-Managerモジュールの構造理解、パターン調査 |
| 実装計画 | `Plan` | 新しいモジュール追加、大規模な設定変更の計画 |
| 設定適用 | `Bash` | `home-manager switch`, `nix-channel --update` |

### 使用例

```
# Home-Managerモジュールの調査
Task(subagent_type=Explore): "macos/.config/home-manager/ 内のモジュール構造を調査"

# 新規パッケージ追加の計画
Task(subagent_type=Plan): "packages.nix に新しい言語サーバーを追加する計画"
```

### エージェント選択の指針

1. **Explore**: 「どこに」「何が」あるかを調べるとき
   - モジュール間の依存関係調査
   - 設定パターンの確認
   - Nixpkgsのオプション調査

2. **Plan**: 「どうやって」実装するかを決めるとき
   - 新しいモジュール追加
   - 複数ファイルにまたがる変更
   - 設定のリファクタリング

3. **Bash**: 実際にコマンドを実行するとき
   - `home-manager switch`
   - `nix search nixpkgs`
   - `nix-channel --update`
