{ pkgs, ... }:

{
  # Git configuration
  programs.git = {
    enable = true;
    userName = "kugue99A";
    userEmail = "hisabisa99yohey@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      core.pager = "delta";
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

      # Image diff support using chafa for text conversion
      diff.image.textconv = "${pkgs.chafa}/bin/chafa --format=symbols --size=80x40";

      # Define image file patterns
      core.attributesfile = "~/.gitattributes_global";
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

  # Lazygit - disabled Home Manager config to allow manual management
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
  #         pager = "delta --dark --paging=never --side-by-side --line-numbers";
  #         useConfig = false;
  #       };
  #     };
  #   };
  # };
}