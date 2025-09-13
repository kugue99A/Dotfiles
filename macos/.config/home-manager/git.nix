{ pkgs, ... }:

{
  # Git configuration
  programs.git = {
    enable = true;
    userName = "yoheikugue";
    userEmail = "your-email@example.com";  # Update this with your email
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = false;
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
    };
  };
}