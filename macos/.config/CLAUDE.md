# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal configuration directory (`~/.config`) containing dotfiles and configuration for various development tools and applications on macOS. The repository includes configurations for shell environments, terminal multiplexers, editors, and system utilities.

## Key Configuration Files and Commands

### Shell Environment (Fish)
- **Configuration**: `fish/config.fish`
- **Key aliases**: `vim` → `nvim`, `vi` → `nvim`, `ls` → `lsd`
- **Important tools**: Starship prompt, Zoxide (cd replacement), Pyenv, Homebrew integration
- **Reload configuration**: `source ~/.config/fish/config.fish`

### Terminal Multiplexer (Zellij)
- **Configuration**: `zellij/config.kdl` 
- **Prefix key**: `Ctrl+q` (tmux-style bindings)
- **Launch session**: `zellij`
- **Key bindings**: Vim-style navigation (hjkl), prefix-based commands matching tmux workflow
- **Theme**: Custom Gruvbox Dark theme

### Text Editor (Neovim)
- **Configuration directory**: `nvim/`
- **Plugin manager**: lazy.nvim
- **Update plugins**: Open Neovim and run `:Lazy sync`
- **LSP management**: Mason (`:Mason` command)
- **Architecture**: Modular setup with individual plugin files in `lua/plugins/`

### Prompt (Starship)
- **Configuration**: `starship.toml`
- **Theme**: Custom Gruvbox Dark color scheme
- **Reload**: Configuration auto-reloads, or restart shell
- **Format**: Multi-segment prompt with OS, user, directory, git, language detection, time

### File Listing (LSD)
- **Configuration**: `lsd/config.yaml`
- **Theme**: Custom Iceberg theme (`lsd/themes/iceberg.yml`)
- **Usage**: Replaces `ls` command via fish alias

### Git UI (Lazygit)
- **Configuration**: `lazygit/config.yml` (currently empty - uses defaults)
- **Launch**: `lazygit` command
- **Environment**: Uses XDG_CONFIG_HOME for configuration discovery

## Architecture and Patterns

### Configuration Management Strategy
The repository follows a modular approach where each tool maintains its configuration in separate directories under `~/.config/`. This aligns with XDG Base Directory specification.

### Key Integration Points
1. **Shell Integration**: Fish shell serves as the central integration point, loading configurations for Starship, Zoxide, and setting up aliases
2. **Theme Consistency**: Gruvbox Dark theme is used consistently across Starship, Zellij, and Neovim for visual coherence
3. **Vim-style Bindings**: Both Zellij and Neovim use vim-style navigation (hjkl keys)
4. **Development Tools**: Environment includes Go, Python (via Pyenv), Node.js, and Haskell (GHCup) development setups

### Plugin and Extension Management
- **Neovim**: Uses lazy.nvim with modular plugin files in `lua/plugins/`
- **Fish**: Uses Fisher package manager (plugins listed in `fish_plugins`)
- **Raycast**: Contains custom color picker extension with TypeScript/React components

### File Organization Principles
- Tool-specific directories under `.config/`
- Separate theme files where supported (lsd, potentially others)
- Backup files maintained (e.g., `config.kdl.bak` for Zellij)
- Lock files for reproducible plugin versions (lazy-lock.json for Neovim)

## Development Workflow

### Making Configuration Changes
1. Edit configuration files directly in their respective directories
2. Most tools auto-reload or require shell restart
3. Neovim plugins require `:Lazy sync` after modifications
4. Test changes before committing

### Common Maintenance Tasks
- Update Neovim plugins: `:Lazy sync` and commit `lazy-lock.json`
- Update Fish plugins: `fisher update`
- Update system tools: `brew upgrade` (Homebrew packages)
- Review and update themes consistently across tools

### Environment Dependencies
- Homebrew for package management
- Fish shell as default interactive shell
- Various language runtimes (Python via Pyenv, Go, Node.js, Haskell via GHCup)
- Development tools: Neovim, Zellij, Starship, LSD, Lazygit, Zoxide