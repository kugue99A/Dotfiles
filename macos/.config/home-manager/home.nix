{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./terminal.nix
  ];

  home.username = "yoheikugue";
  home.homeDirectory = "/Users/yoheikugue";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}