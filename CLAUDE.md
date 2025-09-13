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
1. Add server name to `lsp_servers` table in `init.lua`
2. Create configuration file in `lsp/[server_name].lua`
3. System installation handled via Nix (`packages.nix`)

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
