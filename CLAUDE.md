# CLAUDE.md

日本語で回答

## neovimの問題はこちらを読む
* https://neovim.io/doc/user/lsp.html

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for macOS development environment with a terraform-like management interface. The repository provides comprehensive configuration for Fish shell, Neovim, Zellij terminal multiplexer, and various development tools, all unified under a Gruvbox Dark theme.

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
# Neovim plugin management
nvim +:Lazy sync

# Fish shell reload
source ~/.config/fish/config.fish

# Update Fish plugins
fisher update
```

## Architecture and Management Strategy

### Dual Configuration System
The repository implements a hybrid approach:

1. **Manual Configuration**: Traditional dotfiles managed via the `./dotfiles` script with terraform-like operations
2. **Nix Home Manager**: Declarative package and configuration management for system-level tools

### Key Integration Points

- **Theme Consistency**: All applications use Gruvbox Dark theme (Neovim, Zellij, Starship, terminal)
- **Shell Integration**: Fish shell as the central hub with custom functions, aliases, and environment setup
- **LSP Management**: Neovim uses `vim.lsp.enable` with individual server configuration files in `lsp/` directory
- **Plugin Management**: Lazy.nvim for Neovim, Fisher for Fish shell

### Directory Structure Logic
```
macos/.config/          # Source configurations
├── fish/               # Fish shell with custom functions
├── nvim/               # Modular Neovim setup with lazy.nvim
├── zellij/             # Terminal multiplexer with tmux-like bindings
├── home-manager/       # Nix configuration split by functionality
└── mise/               # Runtime version management
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
1. Create configuration file in `lua/lsp/[server_name].lua`
2. Add server configuration to `lua/core/lsp.lua`
3. System installation handled via Nix (`packages.nix`)

**Important**: LSP configuration uses modern `vim.lsp.config` and `vim.lsp.enable` approach, not Mason. Individual server configs are in `lua/lsp/` directory.

### Theme and Visual Consistency
- Use Gruvbox Dark color scheme across all applications
- Consistent terminal settings (Font: monospace, transparency settings)
- Unified prompt styling via Starship configuration

### Environment Variables and Paths
- Fish shell manages PATH modifications and environment setup
- Mise handles runtime version management (Node.js, Python, Go, etc.)
- Home Manager provides system-level package installation

### State Management
- Manual configurations: Tracked via `.dotfiles_state`
- Nix configurations: Managed via Home Manager generations
- Plugin states: Neovim `lazy-lock.json`, Fish `fish_plugins`

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

### Fish Shell Custom Functions
Located in `fish/functions/`:
- `ga.fish`, `gc.fish`, `gd.fish`, `gl.fish`, `gp.fish`, `gs.fish` - Git shortcuts
- `vf.fish` - Fuzzy finder integration
- `dedup_path.fish` - PATH management

## Troubleshooting Common Issues

### Neovim LSP Problems
- Check `:LspInfo` for server status
- Verify server installation in Nix `packages.nix`
- Review server config in `lua/lsp/[server].lua`
- Restart LSP: `:LspRestart`

### Dotfiles Conflicts
- Check for Nix-managed files: Files managed by Home Manager are automatically skipped
- Review backup location: `~/.config.backup/TIMESTAMP/`
- State conflicts: Check `.dotfiles_state` for tracking issues

### Home Manager Issues
- Channel updates: `nix-channel --update && home-manager switch`
- Generation rollback: `home-manager generations` then activate specific generation
- Detailed errors: `home-manager switch --show-trace`

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
