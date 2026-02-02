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
    ./sketchybar.nix
  ];

  home.username = local.username;
  home.homeDirectory = local.homeDirectory;
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
