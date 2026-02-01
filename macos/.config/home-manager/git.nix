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
    };
  };

  # Lazygit
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          lightTheme = false;
          activeBorderColor = ["#d79921" "bold"];
          inactiveBorderColor = ["#a89984"];
          selectedLineBgColor = ["#3c3836"];
        };
      };
      git = {
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never --side-by-side --line-numbers";
          }
        ];
      };
    };
  };
}
