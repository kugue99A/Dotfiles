{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./terminal.nix
  ];

  home.username = "s26988";
  home.homeDirectory = "/Users/s26988";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}