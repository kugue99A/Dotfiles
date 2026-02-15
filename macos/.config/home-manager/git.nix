{ pkgs, ... }:

let
  local = import ./local.nix;
in
{
  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = local.gitUserName;
        email = local.gitUserEmail;
      };
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        pager = "delta";
        attributesfile = "~/.gitattributes_global";
      };
      pull.rebase = false;
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        dark = true;
        line-numbers = true;
        side-by-side = true;
      };
      merge.conflictStyle = "zdiff3";
      ghq.root = "~/Workspace";

      # Image diff support using custom script with Kitty/Sixel fallback
      diff.image.textconv = "git-image-textconv";
    };
  };

  # Global gitattributes for image file handling
  home.file.".gitattributes_global".text = ''
    # Image files - use chafa for diff display
    *.png diff=image
    *.jpg diff=image
    *.jpeg diff=image
    *.gif diff=image
    *.bmp diff=image
    *.webp diff=image
    *.ico diff=image
    *.svg diff=image
  '';

  # Lazygit - disabled to allow manual configuration
  # programs.lazygit = {
  #   enable = true;
  #   settings = {
  #     gui = {
  #       theme = {
  #         lightTheme = false;
  #         activeBorderColor = ["#d79921" "bold"];
  #         inactiveBorderColor = ["#a89984"];
  #         selectedLineBgColor = ["#3c3836"];
  #       };
  #     };
  #     git = {
  #       paging = {
  #         colorArg = "always";
  #         useConfig = false;
  #       };
  #       pager = "delta --dark --paging=never --side-by-side --line-numbers";
  #     };
  #   };
  # };
}
