{ config, pkgs, ... }:

let
  local = import ./local.nix;
in
{
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./terminal.nix
    ./aerospace.nix
    ./aerokit.nix
    ./sketchybar.nix
    ./tmux.nix
    ./herdr.nix
    ./local-llm.nix
    ./agent-skills.nix
  ];

  home.username = local.username;
  home.homeDirectory = local.homeDirectory;
  home.stateVersion = "25.05";

  home.file.".codex/themes/ashes-light.tmTheme".source = ./themes/ashes-light.tmTheme;
  home.file.".config/fish/functions/codex.fish" = {
    source = ../fish/functions/codex.fish;
    force = true;
  };

  programs.home-manager.enable = true;
}
