{ pkgs, ... }:

{
  # Fish shell configuration (primary shell)
  programs.fish = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      ls = "lsd";
      ll = "lsd -l";
      la = "lsd -la";
      cat = "bat";
      grep = "rg";
      find = "fd";
      imagecat = "/Applications/WezTerm.app/Contents/MacOS/wezterm imgcat";
    };
    shellInit = ''
      # Disable fish greeting
      set fish_greeting
      
      # Starship prompt
      if command -v starship >/dev/null
        starship init fish | source
      end
      
      # Zoxide
      if command -v zoxide >/dev/null
        zoxide init fish | source
      end
      
      # Custom cd function that also lists directory contents
      function cd
        builtin cd $argv[1]
        lsd
      end
      
      # Go environment
      set -x GOPATH $HOME/go
      set -x GOBIN $GOPATH/bin
      set -x PATH $PATH:$GOBIN
      
      # Add local bin to PATH
      set -x PATH $HOME/.local/bin $PATH
      
      # Mise activation
      if command -v mise >/dev/null
        mise activate fish | source
      end

      # gtr (git worktree runner) shell integration
      set -l _gtr_init (test -n "$XDG_CACHE_HOME" && echo $XDG_CACHE_HOME || echo $HOME/.cache)/gtr/init-gtr.fish
      test -f "$_gtr_init"; or git gtr init fish >/dev/null 2>&1
      # Fix Fish 4.x block-scoping bug: use -f (function scope) instead of -l (block scope)
      if test -f "$_gtr_init"; and grep -q 'set -l _gtr_key' "$_gtr_init"
        sed -i "" 's/set -l _gtr_key/set -f _gtr_key/g;s/set -l _gtr_line/set -f _gtr_line/g' "$_gtr_init"
      end
      source "$_gtr_init" 2>/dev/null
    '';
    functions = {
      # Custom function for finding and editing files
      vf = "fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim";
      
      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      
      # Quick directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Benchmark: Fish startup time
      "bench-fish" = ''
        echo "=== Fish Startup Profile (Top 10 slowest) ==="
        set -l tmpfile (mktemp /tmp/fish-profile.XXXXXX)
        fish --profile-startup $tmpfile -c exit
        sort -t$'\t' -k2 -nr $tmpfile | head -10
        rm -f $tmpfile

        echo ""
        echo "=== Hyperfine Benchmark ==="
        hyperfine --warmup 3 --runs 10 "fish -c exit"
      '';

      # Display images in terminal (Kitty → Sixel → symbols fallback)
      imgcat = ''
        if test (count $argv) -eq 0
            echo "Usage: imgcat [--size WxH] <image_file>..."
            return 1
        end

        set -l files
        set -l size ""
        set -l i 1
        while test $i -le (count $argv)
            switch $argv[$i]
                case --size -s
                    set i (math $i + 1)
                    set size $argv[$i]
                case '-*'
                    echo "Unknown option: $argv[$i]"
                    return 1
                case '*'
                    set -a files $argv[$i]
            end
            set i (math $i + 1)
        end

        for file in $files
            if not test -f "$file"
                echo "Error: $file not found"
                continue
            end

            set -l size_arg
            if test -n "$size"
                set size_arg --size=$size
            end

            chafa --format=kitty $size_arg "$file" 2>/dev/null
            or chafa --format=sixels $size_arg "$file" 2>/dev/null
            or chafa --format=symbols $size_arg "$file" 2>/dev/null
            or echo "[Unable to display: $file]"
        end
      '';

      # Benchmark: Neovim startup time
      "bench-nvim" = ''
        echo "=== Neovim Startup Profile (Top 10 slowest) ==="
        set -l tmpfile (mktemp /tmp/nvim-startuptime.XXXXXX)
        nvim --headless --startuptime $tmpfile +quit
        sort -t: -k2 -nr $tmpfile | head -10
        rm -f $tmpfile

        echo ""
        echo "=== Hyperfine Benchmark ==="
        hyperfine --warmup 3 --runs 10 "nvim --headless +quit"
      '';
    };
  };

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "open";
    PAGER = "less";
    MANPAGER = "nvim +Man!";
    SHELL = "${pkgs.fish}/bin/fish";
  };
}