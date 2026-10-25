{ pkgs, ... }:

let
  # Regenerate when package store paths change, rather than on every shell start.
  fishInitScripts = pkgs.runCommand "fish-terminal-init" { } ''
    mkdir -p "$out" "$TMPDIR/starship-cache"
    STARSHIP_CACHE="$TMPDIR/starship-cache" ${pkgs.starship}/bin/starship init fish --print-full-init > "$out/starship.fish"
    ${pkgs.zoxide}/bin/zoxide init fish > "$out/zoxide.fish"
    ${pkgs.fzf}/bin/fzf --fish > "$out/fzf.fish"
  '';
in
{
  home.file.".config/fish/generated/starship.fish".source = "${fishInitScripts}/starship.fish";
  home.file.".config/fish/generated/zoxide.fish".source = "${fishInitScripts}/zoxide.fish";
  home.file.".config/fish/generated/fzf.fish".source = "${fishInitScripts}/fzf.fish";

  programs.fish.interactiveShellInit = ''
    source "$HOME/.config/fish/generated/fzf.fish"
    source "$HOME/.config/fish/generated/zoxide.fish"
    if test "$TERM" != dumb
      source "$HOME/.config/fish/generated/starship.fish"
    end
  '';

  # Font configuration
  fonts.fontconfig.enable = true;
  # Starship configuration
  programs.starship = {
    enable = true;
    enableFishIntegration = false;
    settings = {
      format = "$all$character";
      # Process startup on this host can exceed Starship's 500ms default.
      command_timeout = 2000;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
        vimcmd_symbol = "[➜](bold green)";
      };
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      git_branch = {
        symbol = " ";
      };
      nodejs = {
        symbol = " ";
      };
      python = {
        symbol = " ";
      };
      rust = {
        symbol = " ";
      };
      golang = {
        symbol = " ";
      };
    };
  };

  # Zoxide (smart cd command)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = false;
  };

  # Bat (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
      pager = "less -FR";
    };
  };

  # FZF (fuzzy finder)
  programs.fzf = {
    enable = true;
    enableFishIntegration = false;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
  };
}
