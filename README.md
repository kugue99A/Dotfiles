# Dotfiles Management

This repository contains personal dotfiles for macOS development environment with terraform-like management interface.

## Overview

The dotfiles are organized in `macos/.config/` directory and can be managed using the `./dotfiles` script which provides a terraform-like interface for applying configuration changes.

## Architecture

### Core Applications
- **Fish Shell** - Primary shell with extensive customization
- **Neovim** - Modern Lua-based editor configuration
- **Zellij** - Terminal multiplexer with tmux-like keybindings
- **WezTerm** - Terminal emulator with Gruvbox theme
- **Starship** - Cross-shell prompt (managed by nix)

### Theme
All applications use the **Gruvbox Dark** theme for visual consistency.

## Usage

### Basic Commands

```bash
# Show current status
./dotfiles status

# Plan changes (dry-run)
./dotfiles plan

# Apply configuration
./dotfiles apply

# Remove symlinks
./dotfiles destroy
```

### Workflow

1. **Check Status**: See what's currently managed
   ```bash
   ./dotfiles status
   ```

2. **Plan Changes**: Preview what will be changed
   ```bash
   ./dotfiles plan
   ```

3. **Apply Changes**: Create symlinks and backup existing files
   ```bash
   ./dotfiles apply
   ```

## Features

### Automatic Backup
- Existing configuration files are automatically backed up to `~/.config.backup/TIMESTAMP/`
- Timestamps ensure multiple backups don't overwrite each other

### Nix Integration
- Detects and skips files managed by nix/home-manager
- Prevents conflicts with existing nix-managed configurations

### Safe Operations
- Non-destructive operations by default
- Backup creation before any changes
- Symlink verification to prevent accidental overwrites

### State Management
- Tracks applied configurations in `.dotfiles_state`
- Records backup locations and timestamps

## Configuration Structure

```
macos/.config/
├── fish/           # Fish shell configuration
├── nvim/           # Neovim configuration
├── zellij/         # Zellij terminal multiplexer
├── wezterm/        # WezTerm terminal emulator
├── starship.toml   # Starship prompt (managed by nix)
└── ...             # Other application configs
```

## Safety Features

- **Backup Creation**: All existing files are backed up before changes
- **Nix Detection**: Automatically skips nix-managed files
- **Symlink Verification**: Ensures symlinks point to correct locations
- **State Tracking**: Maintains state file for rollback capabilities

## Restoration

If you need to restore from backup:

```bash
# Find your backup directory
ls ~/.config.backup/

# Restore specific config
cp ~/.config.backup/TIMESTAMP/nvim ~/.config/nvim

# Or restore everything
rm -rf ~/.config
mv ~/.config.backup/TIMESTAMP ~/.config
```

## Contributing

When adding new configurations:
1. Place them in `macos/.config/`
2. Maintain Gruvbox Dark theme consistency
3. Test with `./dotfiles plan` before committing
4. Update this README if needed

## Notes

- This is a personal dotfiles repository
- No automatic installation scripts are provided
- Manual setup of applications is required
- Symlinks are created to this repository location